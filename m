Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CACC6B026A
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 19:49:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so9113805pfi.15
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 16:49:50 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0103.outbound.protection.outlook.com. [104.47.1.103])
        by mx.google.com with ESMTPS id v68si5280520pgv.557.2017.12.15.16.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 16:49:47 -0800 (PST)
Date: Fri, 15 Dec 2017 16:49:28 -0800
From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [2/2] fs, elf: drop MAP_FIXED usage from elf_map
Message-ID: <20171216004927.GA14956@outlook.office365.com>
References: <20171213092550.2774-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <20171213092550.2774-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

Hi Michal,

We run CRIU tests for linux-next and the 4.15.0-rc3-next-20171215 kernel
doesn't boot:

[    3.492549] Freeing unused kernel memory: 1640K
[    3.494547] Write protecting the kernel read-only data: 18432k
[    3.498781] Freeing unused kernel memory: 2016K
[    3.503330] Freeing unused kernel memory: 512K
[    3.505232] rodata_test: all tests were successful
[    3.515355] 1 (init): Uhuuh, elf segement at 00000000928fda3e requested but the memory is mapped already
[    3.519533] Starting init: /sbin/init exists but couldn't execute it (error -95)
[    3.528993] Starting init: /bin/sh exists but couldn't execute it (error -14)
[    3.532127] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
[    3.538328] CPU: 0 PID: 1 Comm: init Not tainted 4.15.0-rc3-next-20171215-00001-g6d6aea478fce #11
[    3.542201] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
[    3.546081] Call Trace:
[    3.547221]  dump_stack+0x5c/0x79
[    3.548768]  ? rest_init+0x30/0xb0
[    3.550320]  panic+0xe4/0x232
[    3.551669]  ? rest_init+0xb0/0xb0
[    3.553110]  kernel_init+0xeb/0x100
[    3.554701]  ret_from_fork+0x1f/0x30
[    3.558964] Kernel Offset: 0x2000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[    3.564160] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.

If I revert this patch, it boots normally.

Thanks,
Andrei

On Wed, Dec 13, 2017 at 10:25:50AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Both load_elf_interp and load_elf_binary rely on elf_map to map segments
> on a controlled address and they use MAP_FIXED to enforce that. This is
> however dangerous thing prone to silent data corruption which can be
> even exploitable. Let's take CVE-2017-1000253 as an example. At the time
> (before eab09532d400 ("binfmt_elf: use ELF_ET_DYN_BASE only for PIE"))
> ELF_ET_DYN_BASE was at TASK_SIZE / 3 * 2 which is not that far away from
> the stack top on 32b (legacy) memory layout (only 1GB away). Therefore
> we could end up mapping over the existing stack with some luck.
> 
> The issue has been fixed since then (a87938b2e246 ("fs/binfmt_elf.c:
> fix bug in loading of PIE binaries")), ELF_ET_DYN_BASE moved moved much
> further from the stack (eab09532d400 and later by c715b72c1ba4 ("mm:
> revert x86_64 and arm64 ELF_ET_DYN_BASE base changes")) and excessive
> stack consumption early during execve fully stopped by da029c11e6b1
> ("exec: Limit arg stack to at most 75% of _STK_LIM"). So we should be
> safe and any attack should be impractical. On the other hand this is
> just too subtle assumption so it can break quite easily and hard to
> spot.
> 
> I believe that the MAP_FIXED usage in load_elf_binary (et. al) is still
> fundamentally dangerous. Moreover it shouldn't be even needed. We are
> at the early process stage and so there shouldn't be unrelated mappings
> (except for stack and loader) existing so mmap for a given address
> should succeed even without MAP_FIXED. Something is terribly wrong if
> this is not the case and we should rather fail than silently corrupt the
> underlying mapping.
> 
> Address this issue by changing MAP_FIXED to the newly added
> MAP_FIXED_SAFE. This will mean that mmap will fail if there is an
> existing mapping clashing with the requested one without clobbering it.
> 
> Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
> Cc: Joel Stanley <joel@jms.id.au>
> Acked-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/metag/kernel/process.c |  6 +++++-
>  fs/binfmt_elf.c             | 12 ++++++++----
>  2 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
> index 0909834c83a7..867c8d0a5fb4 100644
> --- a/arch/metag/kernel/process.c
> +++ b/arch/metag/kernel/process.c
> @@ -399,7 +399,7 @@ unsigned long __metag_elf_map(struct file *filep, unsigned long addr,
>  	tcm_tag = tcm_lookup_tag(addr);
>  
>  	if (tcm_tag != TCM_INVALID_TAG)
> -		type &= ~MAP_FIXED;
> +		type &= ~(MAP_FIXED | MAP_FIXED_SAFE);
>  
>  	/*
>  	* total_size is the size of the ELF (interpreter) image.
> @@ -417,6 +417,10 @@ unsigned long __metag_elf_map(struct file *filep, unsigned long addr,
>  	} else
>  		map_addr = vm_mmap(filep, addr, size, prot, type, off);
>  
> +	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr))
> +		pr_info("%d (%s): Uhuuh, elf segement at %p requested but the memory is mapped already\n",
> +				task_pid_nr(current), tsk->comm, (void*)addr);
> +
>  	if (!BAD_ADDR(map_addr) && tcm_tag != TCM_INVALID_TAG) {
>  		struct tcm_allocation *tcm;
>  		unsigned long tcm_addr;
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 73b01e474fdc..5916d45f64a7 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -372,6 +372,10 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
>  	} else
>  		map_addr = vm_mmap(filep, addr, size, prot, type, off);
>  
> +	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr))
> +		pr_info("%d (%s): Uhuuh, elf segement at %p requested but the memory is mapped already\n",
> +				task_pid_nr(current), current->comm, (void*)addr);
> +
>  	return(map_addr);
>  }
>  
> @@ -569,7 +573,7 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>  				elf_prot |= PROT_EXEC;
>  			vaddr = eppnt->p_vaddr;
>  			if (interp_elf_ex->e_type == ET_EXEC || load_addr_set)
> -				elf_type |= MAP_FIXED;
> +				elf_type |= MAP_FIXED_SAFE;
>  			else if (no_base && interp_elf_ex->e_type == ET_DYN)
>  				load_addr = -vaddr;
>  
> @@ -930,7 +934,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  		 * the ET_DYN load_addr calculations, proceed normally.
>  		 */
>  		if (loc->elf_ex.e_type == ET_EXEC || load_addr_set) {
> -			elf_flags |= MAP_FIXED;
> +			elf_flags |= MAP_FIXED_SAFE;
>  		} else if (loc->elf_ex.e_type == ET_DYN) {
>  			/*
>  			 * This logic is run once for the first LOAD Program
> @@ -966,7 +970,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  				load_bias = ELF_ET_DYN_BASE;
>  				if (current->flags & PF_RANDOMIZE)
>  					load_bias += arch_mmap_rnd();
> -				elf_flags |= MAP_FIXED;
> +				elf_flags |= MAP_FIXED_SAFE;
>  			} else
>  				load_bias = 0;
>  
> @@ -1223,7 +1227,7 @@ static int load_elf_library(struct file *file)
>  			(eppnt->p_filesz +
>  			 ELF_PAGEOFFSET(eppnt->p_vaddr)),
>  			PROT_READ | PROT_WRITE | PROT_EXEC,
> -			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
> +			MAP_FIXED_SAFE | MAP_PRIVATE | MAP_DENYWRITE,
>  			(eppnt->p_offset -
>  			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
>  	if (error != ELF_PAGESTART(eppnt->p_vaddr))

--uAKRQypu60I7Lcqm
Content-Type: application/gzip
Content-Disposition: attachment; filename="config.gz"
Content-Transfer-Encoding: base64

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

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="dmesg.txt"

[    0.000000] Linux version 4.15.0-rc3-next-20171215-00001-g6d6aea478fce (avagin@laptop) (gcc version 7.2.1 20170915 (Red Hat 7.2.1-2) (GCC)) #11 SMP Fri Dec 15 16:39:11 PST 2017
[    0.000000] Command line: root=/dev/vda2 ro debug console=ttyS0,115200 LANG=en_US.UTF-8 slub_debug=FZP raid=noautodetect selinux=0
[    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x008: 'MPX bounds registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x010: 'MPX CSR'
[    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.000000] x86/fpu: xstate_offset[3]:  832, xstate_sizes[3]:   64
[    0.000000] x86/fpu: xstate_offset[4]:  896, xstate_sizes[4]:   64
[    0.000000] x86/fpu: Enabled xstate features 0x1f, context size is 960 bytes, using 'compacted' format.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007ffd8fff] usable
[    0.000000] BIOS-e820: [mem 0x000000007ffd9000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x7ffd9 max_arch_pfn = 0x400000000
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
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
[    0.000000] found SMP MP-table at [mem 0x000f6bd0-0x000f6bdf] mapped at [        (ptrval)]
[    0.000000] Base memory trampoline at [        (ptrval)] 99000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] BRK [0x2c984000, 0x2c984fff] PGTABLE
[    0.000000] BRK [0x2c985000, 0x2c985fff] PGTABLE
[    0.000000] BRK [0x2c986000, 0x2c986fff] PGTABLE
[    0.000000] BRK [0x2c987000, 0x2c987fff] PGTABLE
[    0.000000] BRK [0x2c988000, 0x2c988fff] PGTABLE
[    0.000000] BRK [0x2c989000, 0x2c989fff] PGTABLE
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F69C0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000007FFE12FF 00002C (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000007FFE120B 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000007FFE0040 0011CB (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000007FFE0000 000040
[    0.000000] ACPI: APIC 0x000000007FFE127F 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000007ffd8fff]
[    0.000000] NODE_DATA(0) allocated [mem 0x7ffc2000-0x7ffd8fff]
[    0.000000] kvm-clock: cpu 0, msr 0:7ffc0001, primary cpu clock
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: using sched offset of 1076013277 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffd8fff]
[    0.000000]   Normal   empty
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007ffd8fff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007ffd8fff]
[    0.000000] On node 0 totalpages: 524151
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 8128 pages used for memmap
[    0.000000]   DMA32 zone: 520153 pages, LIFO batch:31
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x80000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] percpu: Embedded 44 pages/cpu @        (ptrval) s142296 r8192 d29736 u1048576
[    0.000000] pcpu-alloc: s142296 r8192 d29736 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 7fc122c0
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 515938
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: root=/dev/vda2 ro debug console=ttyS0,115200 LANG=en_US.UTF-8 slub_debug=FZP raid=noautodetect selinux=0
[    0.000000] Memory: 2037056K/2096604K available (12300K kernel code, 1554K rwdata, 3584K rodata, 1640K init, 912K bss, 59548K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] ftrace: allocating 36554 entries in 143 pages
[    0.001000] Hierarchical RCU implementation.
[    0.001000] 	RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=2.
[    0.001000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
[    0.001000] NR_IRQS: 4352, nr_irqs: 440, preallocated irqs: 16
[    0.001000] 	Offload RCU callbacks from CPUs: (none).
[    0.001000] Console: colour dummy device 80x25
[    0.001000] console [ttyS0] enabled
[    0.001000] ACPI: Core revision 20171110
[    0.001000] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.001009] APIC: Switch to symmetric I/O mode setup
[    0.001571] x2apic enabled
[    0.002003] Switched APIC routing to physical x2apic.
[    0.003538] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.004000] tsc: Detected 2496.000 MHz processor
[    0.004014] Calibrating delay loop (skipped) preset value.. 4992.00 BogoMIPS (lpj=2496000)
[    0.005014] pid_max: default: 32768 minimum: 301
[    0.006057] Security Framework initialized
[    0.006548] Yama: becoming mindful.
[    0.007019] SELinux:  Disabled at boot.
[    0.008206] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.009164] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.009816] Mount-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.010009] Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.011322] mce: CPU supports 10 MCE banks
[    0.011740] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.012002] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.012610] Freeing SMP alternatives memory: 36K
[    0.013467] TSC deadline timer enabled
[    0.013820] smpboot: CPU0: Intel Core Processor (Skylake) (family: 0x6, model: 0x5e, stepping: 0x3)
[    0.014000] Performance Events: unsupported p6 CPU model 94 no PMU driver, software events only.
[    0.014041] Hierarchical SRCU implementation.
[    0.015133] NMI watchdog: Perf event create on CPU 0 failed with -2
[    0.015725] NMI watchdog: Perf NMI watchdog permanently disabled
[    0.016077] smp: Bringing up secondary CPUs ...
[    0.016654] x86: Booting SMP configuration:
[    0.017005] .... node  #0, CPUs:      #1
[    0.001000] kvm-clock: cpu 1, msr 0:7ffc0041, secondary cpu clock
[    0.019051] KVM setup async PF for cpu 1
[    0.019599] kvm-stealtime: cpu 1, msr 7fd122c0
[    0.020009] smp: Brought up 1 node, 2 CPUs
[    0.020531] smpboot: Max logical packages: 2
[    0.021009] smpboot: Total of 2 processors activated (9984.00 BogoMIPS)
[    0.023160] devtmpfs: initialized
[    0.023513] x86/mm: Memory block size: 128MB
[    0.024811] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.025015] futex hash table entries: 512 (order: 3, 32768 bytes)
[    0.026185] RTC time:  0:42:06, date: 12/16/17
[    0.026790] NET: Registered protocol family 16
[    0.027204] audit: initializing netlink subsys (disabled)
[    0.027914] audit: type=2000 audit(1513384927.133:1): state=initialized audit_enabled=0 res=1
[    0.028185] cpuidle: using governor menu
[    0.029118] ACPI: bus type PCI registered
[    0.029872] PCI: Using configuration type 1 for base access
[    0.034355] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    0.035011] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.036066] cryptd: max_cpu_qlen set to 1000
[    0.036579] ACPI: Added _OSI(Module Device)
[    0.037007] ACPI: Added _OSI(Processor Device)
[    0.037426] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.037857] ACPI: Added _OSI(Processor Aggregator Device)
[    0.041356] ACPI: Interpreter enabled
[    0.041764] ACPI: (supports S0 S5)
[    0.042005] ACPI: Using IOAPIC for interrupt routing
[    0.042655] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.043625] ACPI: Enabled 2 GPEs in block 00 to 0F
[    0.059248] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.059953] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
[    0.060045] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.061180] PCI host bridge to bus 0000:00
[    0.061874] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.062013] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.063016] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.064015] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebfffff window]
[    0.065014] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.065753] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.066487] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.067537] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.071700] pci 0000:00:01.1: reg 0x20: [io  0xc100-0xc10f]
[    0.074032] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.074908] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.075011] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.076010] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.077121] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.078148] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.079014] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.080224] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.082007] pci 0000:00:03.0: reg 0x10: [io  0xc040-0xc05f]
[    0.083814] pci 0000:00:03.0: reg 0x14: [mem 0xfebc0000-0xfebc0fff]
[    0.089891] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.090545] pci 0000:00:05.0: [1af4:1003] type 00 class 0x078000
[    0.092708] pci 0000:00:05.0: reg 0x10: [io  0xc060-0xc07f]
[    0.094009] pci 0000:00:05.0: reg 0x14: [mem 0xfebc1000-0xfebc1fff]
[    0.102484] pci 0000:00:06.0: [8086:2934] type 00 class 0x0c0300
[    0.108028] pci 0000:00:06.0: reg 0x20: [io  0xc080-0xc09f]
[    0.110738] pci 0000:00:06.1: [8086:2935] type 00 class 0x0c0300
[    0.114388] pci 0000:00:06.1: reg 0x20: [io  0xc0a0-0xc0bf]
[    0.117339] pci 0000:00:06.2: [8086:2936] type 00 class 0x0c0300
[    0.122770] pci 0000:00:06.2: reg 0x20: [io  0xc0c0-0xc0df]
[    0.124738] pci 0000:00:06.7: [8086:293a] type 00 class 0x0c0320
[    0.125825] pci 0000:00:06.7: reg 0x10: [mem 0xfebc2000-0xfebc2fff]
[    0.130347] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.133007] pci 0000:00:07.0: reg 0x10: [io  0xc000-0xc03f]
[    0.134793] pci 0000:00:07.0: reg 0x14: [mem 0xfebc3000-0xfebc3fff]
[    0.141808] pci 0000:00:08.0: [1af4:1002] type 00 class 0x00ff00
[    0.142914] pci 0000:00:08.0: reg 0x10: [io  0xc0e0-0xc0ff]
[    0.148977] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.149455] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.150390] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.151382] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.152380] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.154508] vgaarb: loaded
[    0.155271] SCSI subsystem initialized
[    0.155887] EDAC MC: Ver: 3.0.0
[    0.156255] PCI: Using ACPI for IRQ routing
[    0.156566] PCI: pci_cache_line_size set to 64 bytes
[    0.157161] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.157914] e820: reserve RAM buffer [mem 0x7ffd9000-0x7fffffff]
[    0.158253] NetLabel: Initializing
[    0.158765] NetLabel:  domain hash size = 128
[    0.159005] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
[    0.159775] NetLabel:  unlabeled traffic allowed by default
[    0.160073] clocksource: Switched to clocksource kvm-clock
[    0.186764] VFS: Disk quotas dquot_6.6.0
[    0.187277] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.188251] FS-Cache: Loaded
[    0.188725] pnp: PnP ACPI init
[    0.189271] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.190231] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.191229] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.192096] pnp 00:03: [dma 2]
[    0.192514] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.193631] pnp 00:04: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.195416] pnp: PnP ACPI: found 5 devices
[    0.206055] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.207127] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.207832] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.208594] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    0.209469] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff window]
[    0.210493] NET: Registered protocol family 2
[    0.211244] tcp_listen_portaddr_hash hash table entries: 1024 (order: 2, 16384 bytes)
[    0.212283] TCP established hash table entries: 16384 (order: 5, 131072 bytes)
[    0.213285] TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
[    0.214306] TCP: Hash tables configured (established 16384 bind 16384)
[    0.215065] UDP hash table entries: 1024 (order: 3, 32768 bytes)
[    0.215797] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
[    0.217934] NET: Registered protocol family 1
[    0.219126] RPC: Registered named UNIX socket transport module.
[    0.219676] RPC: Registered udp transport module.
[    0.220130] RPC: Registered tcp transport module.
[    0.220552] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.221153] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.221701] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.222319] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.444214] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    0.880141] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    1.311493] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    1.748829] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    1.962124] PCI: CLS 0 bytes, default 64
[    1.964749] Initialise system trusted keyrings
[    1.965289] workingset: timestamp_bits=37 max_order=19 bucket_order=0
[    1.969600] zbud: loaded
[    1.971287] SGI XFS with security attributes, no debug enabled
[    2.106071] NET: Registered protocol family 38
[    2.106556] Key type asymmetric registered
[    2.106931] Asymmetric key parser 'x509' registered
[    2.107514] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
[    2.108327] io scheduler noop registered
[    2.108813] io scheduler deadline registered
[    2.109608] io scheduler cfq registered (default)
[    2.110258] io scheduler mq-deadline registered
[    2.110796] io scheduler kyber registered
[    2.111688] intel_idle: Please enable MWAIT in BIOS SETUP
[    2.112310] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    2.113037] ACPI: Power Button [PWRF]
[    2.331642] virtio-pci 0000:00:03.0: virtio_pci: leaving for legacy driver
[    2.554093] virtio-pci 0000:00:05.0: virtio_pci: leaving for legacy driver
[    2.775938] virtio-pci 0000:00:07.0: virtio_pci: leaving for legacy driver
[    2.975053] tsc: Refined TSC clocksource calibration: 2495.981 MHz
[    2.975641] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x23fa6529869, max_idle_ns: 440795218057 ns
[    3.029409] virtio-pci 0000:00:08.0: virtio_pci: leaving for legacy driver
[    3.032925] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    3.056849] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    3.064748] Non-volatile memory driver v1.3
[    3.065925] ppdev: user-space parallel port driver
[    3.071816] loop: module loaded
[    3.075337]  vda: vda1 vda2 vda3
[    3.076659] Rounding down aligned max_sectors from 4294967295 to 4294967288
[    3.077996] Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[    3.079790] libphy: Fixed MDIO Bus: probed
[    3.080257] tun: Universal TUN/TAP device driver, 1.6
[    3.082222] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    3.083675] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.084160] serio: i8042 AUX port at 0x60,0x64 irq 12
[    3.084816] mousedev: PS/2 mouse device common for all mice
[    3.086603] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    3.089192] rtc_cmos 00:00: RTC can wake from S4
[    3.090116] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    3.092829] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes nvram
[    3.093937] IR NEC protocol handler initialized
[    3.094408] IR RC5(x/sz) protocol handler initialized
[    3.094901] IR RC6 protocol handler initialized
[    3.095510] IR JVC protocol handler initialized
[    3.095952] IR Sony protocol handler initialized
[    3.096399] IR SANYO protocol handler initialized
[    3.096862] IR Sharp protocol handler initialized
[    3.097342] IR MCE Keyboard/mouse protocol handler initialized
[    3.097919] IR XMP protocol handler initialized
[    3.098530] device-mapper: uevent: version 1.0.3
[    3.099209] device-mapper: ioctl: 4.37.0-ioctl (2017-09-20) initialised: dm-devel@redhat.com
[    3.100398] device-mapper: multipath round-robin: version 1.2.0 loaded
[    3.101883] drop_monitor: Initializing network drop monitor service
[    3.102553] Netfilter messages via NETLINK v0.30.
[    3.103090] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    3.103738] ctnetlink v0.93: registering with nfnetlink.
[    3.104494] ip_tables: (C) 2000-2006 Netfilter Core Team
[    3.105734] Initializing XFRM netlink socket
[    3.106885] NET: Registered protocol family 10
[    3.109341] Segment Routing with IPv6
[    3.109976] mip6: Mobile IPv6
[    3.111987] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    3.114230] NET: Registered protocol family 17
[    3.115047] Bridge firewalling registered
[    3.115824] Ebtables v2.0 registered
[    3.117996] 8021q: 802.1Q VLAN Support v1.8
[    3.119429] AVX2 version of gcm_enc/dec engaged.
[    3.119886] AES CTR mode by8 optimization enabled
[    3.128818] sched_clock: Marking stable (3128714579, 0)->(3404180881, -275466302)
[    3.129945] registered taskstats version 1
[    3.130427] Loading compiled-in X.509 certificates
[    3.163216] Loaded X.509 cert 'Build time autogenerated kernel key: 38e0adea1af8bd8a23b02436d4acf2f8c7408d23'
[    3.166359] zswap: loaded using pool lzo/zbud
[    3.167943] Key type big_key registered
[    3.168778]   Magic number: 13:918:708
[    3.169255] rtc_cmos 00:00: setting system clock to 2017-12-16 00:42:09 UTC (1513384929)
[    3.170604] md: Skipping autodetection of RAID arrays. (raid=autodetect will force)
[    3.171932] EXT4-fs (vda2): couldn't mount as ext3 due to feature incompatibilities
[    3.173871] EXT4-fs (vda2): couldn't mount as ext2 due to feature incompatibilities
[    3.175306] EXT4-fs (vda2): INFO: recovery required on readonly filesystem
[    3.176212] EXT4-fs (vda2): write access will be enabled during recovery
[    3.397187] EXT4-fs (vda2): orphan cleanup on readonly fs
[    3.399412] EXT4-fs (vda2): 5 orphan inodes deleted
[    3.402759] EXT4-fs (vda2): recovery complete
[    3.466647] EXT4-fs (vda2): mounted filesystem with ordered data mode. Opts: (null)
[    3.469401] VFS: Mounted root (ext4 filesystem) readonly on device 253:2.
[    3.473719] devtmpfs: mounted
[    3.492549] Freeing unused kernel memory: 1640K
[    3.494547] Write protecting the kernel read-only data: 18432k
[    3.498781] Freeing unused kernel memory: 2016K
[    3.503330] Freeing unused kernel memory: 512K
[    3.505232] rodata_test: all tests were successful
[    3.515355] 1 (init): Uhuuh, elf segement at 00000000928fda3e requested but the memory is mapped already
[    3.519533] Starting init: /sbin/init exists but couldn't execute it (error -95)
[    3.528993] Starting init: /bin/sh exists but couldn't execute it (error -14)
[    3.532127] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
[    3.538328] CPU: 0 PID: 1 Comm: init Not tainted 4.15.0-rc3-next-20171215-00001-g6d6aea478fce #11
[    3.542201] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
[    3.546081] Call Trace:
[    3.547221]  dump_stack+0x5c/0x79
[    3.548768]  ? rest_init+0x30/0xb0
[    3.550320]  panic+0xe4/0x232
[    3.551669]  ? rest_init+0xb0/0xb0
[    3.553110]  kernel_init+0xeb/0x100
[    3.554701]  ret_from_fork+0x1f/0x30
[    3.558964] Kernel Offset: 0x2000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[    3.564160] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.

--uAKRQypu60I7Lcqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
