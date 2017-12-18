Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 831C76B0069
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:12:39 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f2so5792803plj.15
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 10:12:39 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0131.outbound.protection.outlook.com. [104.47.0.131])
        by mx.google.com with ESMTPS id v12si9745543plk.720.2017.12.18.10.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 10:12:36 -0800 (PST)
Date: Mon, 18 Dec 2017 10:12:17 -0800
From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [2/2] fs, elf: drop MAP_FIXED usage from elf_map
Message-ID: <20171218181215.GA28489@outlook.office365.com>
References: <20171213092550.2774-3-mhocko@kernel.org>
 <20171216004927.GA14956@outlook.office365.com>
 <20171218091302.GL16951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20171218091302.GL16951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>

On Mon, Dec 18, 2017 at 10:13:02AM +0100, Michal Hocko wrote:
> On Fri 15-12-17 16:49:28, Andrei Vagin wrote:
> > Hi Michal,
> > 
> > We run CRIU tests for linux-next and the 4.15.0-rc3-next-20171215 kernel
> > doesn't boot:
> > 
> > [    3.492549] Freeing unused kernel memory: 1640K
> > [    3.494547] Write protecting the kernel read-only data: 18432k
> > [    3.498781] Freeing unused kernel memory: 2016K
> > [    3.503330] Freeing unused kernel memory: 512K
> > [    3.505232] rodata_test: all tests were successful
> > [    3.515355] 1 (init): Uhuuh, elf segement at 00000000928fda3e requested but the memory is mapped already
> 
> Hmm, this interesting. What does the test actualy do? Could you add some
> instrumentation to see what is actually mapped there? Something like

There is nothing mapped there. It returns -95 (ENOSUPP)

The kernel is booted with this patch:

+       int ttype = type & ~MAP_FIXED_SAFE;
        if (total_size) {
                total_size = ELF_PAGEALIGN(total_size);
-               map_addr = vm_mmap(filep, addr, total_size, prot, type,
                off);
+               map_addr = vm_mmap(filep, addr, total_size, prot, ttype, off);
                if (!BAD_ADDR(map_addr))
                        vm_munmap(map_addr+size, total_size-size);
        } else
-               map_addr = vm_mmap(filep, addr, size, prot, type, off);
+               map_addr = vm_mmap(filep, addr, size, prot, ttype, off);


> 
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 0e50230ce53d..1b68ddc34043 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -372,10 +372,28 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
>  	} else
>  		map_addr = vm_mmap(filep, addr, size, prot, type, off);
>  
> -	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr))
> +	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr)) {
> +		struct vm_area_struct *vma;
> +
>  		pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
>  				task_pid_nr(current), current->comm,
>  				(void *)addr);
> +		vma = find_vma(current->mm, map_addr);
> +		if (vma && vma->vm_start < addr) {
> +			pr_info("requested [%lx, %lx] mapped [%lx, %lx] %lx ", addr, addr + total_size,
> +					vma->vm_start, vma->vm_end, vma->vm_flags);
> +			if (!vma->vm_file) {
> +				pr_cont("anon\n");
> +			} else {
> +				char path[512];
> +				char *p = file_path(vma->vm_file, path, sizeof(path));
> +				if (IS_ERR(p))
> +					p = "?";
> +				pr_cont("\"%s\"\n", kbasename(p));
> +			}
> +			dump_stack();
> +		}
> +	}
>  
>  	return(map_addr);
>  }
> 
> > [    3.519533] Starting init: /sbin/init exists but couldn't execute it (error -95)
> > [    3.528993] Starting init: /bin/sh exists but couldn't execute it (error -14)
> > [    3.532127] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
> > [    3.538328] CPU: 0 PID: 1 Comm: init Not tainted 4.15.0-rc3-next-20171215-00001-g6d6aea478fce #11
> > [    3.542201] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
> > [    3.546081] Call Trace:
> > [    3.547221]  dump_stack+0x5c/0x79
> > [    3.548768]  ? rest_init+0x30/0xb0
> > [    3.550320]  panic+0xe4/0x232
> > [    3.551669]  ? rest_init+0xb0/0xb0
> > [    3.553110]  kernel_init+0xeb/0x100
> > [    3.554701]  ret_from_fork+0x1f/0x30
> > [    3.558964] Kernel Offset: 0x2000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> > [    3.564160] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
> > 
> > If I revert this patch, it boots normally.
> > 
> > Thanks,
> > Andrei
> > 
> > On Wed, Dec 13, 2017 at 10:25:50AM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > Both load_elf_interp and load_elf_binary rely on elf_map to map segments
> > > on a controlled address and they use MAP_FIXED to enforce that. This is
> > > however dangerous thing prone to silent data corruption which can be
> > > even exploitable. Let's take CVE-2017-1000253 as an example. At the time
> > > (before eab09532d400 ("binfmt_elf: use ELF_ET_DYN_BASE only for PIE"))
> > > ELF_ET_DYN_BASE was at TASK_SIZE / 3 * 2 which is not that far away from
> > > the stack top on 32b (legacy) memory layout (only 1GB away). Therefore
> > > we could end up mapping over the existing stack with some luck.
> > > 
> > > The issue has been fixed since then (a87938b2e246 ("fs/binfmt_elf.c:
> > > fix bug in loading of PIE binaries")), ELF_ET_DYN_BASE moved moved much
> > > further from the stack (eab09532d400 and later by c715b72c1ba4 ("mm:
> > > revert x86_64 and arm64 ELF_ET_DYN_BASE base changes")) and excessive
> > > stack consumption early during execve fully stopped by da029c11e6b1
> > > ("exec: Limit arg stack to at most 75% of _STK_LIM"). So we should be
> > > safe and any attack should be impractical. On the other hand this is
> > > just too subtle assumption so it can break quite easily and hard to
> > > spot.
> > > 
> > > I believe that the MAP_FIXED usage in load_elf_binary (et. al) is still
> > > fundamentally dangerous. Moreover it shouldn't be even needed. We are
> > > at the early process stage and so there shouldn't be unrelated mappings
> > > (except for stack and loader) existing so mmap for a given address
> > > should succeed even without MAP_FIXED. Something is terribly wrong if
> > > this is not the case and we should rather fail than silently corrupt the
> > > underlying mapping.
> > > 
> > > Address this issue by changing MAP_FIXED to the newly added
> > > MAP_FIXED_SAFE. This will mean that mmap will fail if there is an
> > > existing mapping clashing with the requested one without clobbering it.
> > > 
> > > Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
> > > Cc: Joel Stanley <joel@jms.id.au>
> > > Acked-by: Kees Cook <keescook@chromium.org>
> > > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  arch/metag/kernel/process.c |  6 +++++-
> > >  fs/binfmt_elf.c             | 12 ++++++++----
> > >  2 files changed, 13 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
> > > index 0909834c83a7..867c8d0a5fb4 100644
> > > --- a/arch/metag/kernel/process.c
> > > +++ b/arch/metag/kernel/process.c
> > > @@ -399,7 +399,7 @@ unsigned long __metag_elf_map(struct file *filep, unsigned long addr,
> > >  	tcm_tag = tcm_lookup_tag(addr);
> > >  
> > >  	if (tcm_tag != TCM_INVALID_TAG)
> > > -		type &= ~MAP_FIXED;
> > > +		type &= ~(MAP_FIXED | MAP_FIXED_SAFE);
> > >  
> > >  	/*
> > >  	* total_size is the size of the ELF (interpreter) image.
> > > @@ -417,6 +417,10 @@ unsigned long __metag_elf_map(struct file *filep, unsigned long addr,
> > >  	} else
> > >  		map_addr = vm_mmap(filep, addr, size, prot, type, off);
> > >  
> > > +	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr))
> > > +		pr_info("%d (%s): Uhuuh, elf segement at %p requested but the memory is mapped already\n",
> > > +				task_pid_nr(current), tsk->comm, (void*)addr);
> > > +
> > >  	if (!BAD_ADDR(map_addr) && tcm_tag != TCM_INVALID_TAG) {
> > >  		struct tcm_allocation *tcm;
> > >  		unsigned long tcm_addr;
> > > diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> > > index 73b01e474fdc..5916d45f64a7 100644
> > > --- a/fs/binfmt_elf.c
> > > +++ b/fs/binfmt_elf.c
> > > @@ -372,6 +372,10 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
> > >  	} else
> > >  		map_addr = vm_mmap(filep, addr, size, prot, type, off);
> > >  
> > > +	if ((type & MAP_FIXED_SAFE) && BAD_ADDR(map_addr))
> > > +		pr_info("%d (%s): Uhuuh, elf segement at %p requested but the memory is mapped already\n",
> > > +				task_pid_nr(current), current->comm, (void*)addr);
> > > +
> > >  	return(map_addr);
> > >  }
> > >  
> > > @@ -569,7 +573,7 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
> > >  				elf_prot |= PROT_EXEC;
> > >  			vaddr = eppnt->p_vaddr;
> > >  			if (interp_elf_ex->e_type == ET_EXEC || load_addr_set)
> > > -				elf_type |= MAP_FIXED;
> > > +				elf_type |= MAP_FIXED_SAFE;
> > >  			else if (no_base && interp_elf_ex->e_type == ET_DYN)
> > >  				load_addr = -vaddr;
> > >  
> > > @@ -930,7 +934,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
> > >  		 * the ET_DYN load_addr calculations, proceed normally.
> > >  		 */
> > >  		if (loc->elf_ex.e_type == ET_EXEC || load_addr_set) {
> > > -			elf_flags |= MAP_FIXED;
> > > +			elf_flags |= MAP_FIXED_SAFE;
> > >  		} else if (loc->elf_ex.e_type == ET_DYN) {
> > >  			/*
> > >  			 * This logic is run once for the first LOAD Program
> > > @@ -966,7 +970,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
> > >  				load_bias = ELF_ET_DYN_BASE;
> > >  				if (current->flags & PF_RANDOMIZE)
> > >  					load_bias += arch_mmap_rnd();
> > > -				elf_flags |= MAP_FIXED;
> > > +				elf_flags |= MAP_FIXED_SAFE;
> > >  			} else
> > >  				load_bias = 0;
> > >  
> > > @@ -1223,7 +1227,7 @@ static int load_elf_library(struct file *file)
> > >  			(eppnt->p_filesz +
> > >  			 ELF_PAGEOFFSET(eppnt->p_vaddr)),
> > >  			PROT_READ | PROT_WRITE | PROT_EXEC,
> > > -			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
> > > +			MAP_FIXED_SAFE | MAP_PRIVATE | MAP_DENYWRITE,
> > >  			(eppnt->p_offset -
> > >  			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
> > >  	if (error != ELF_PAGESTART(eppnt->p_vaddr))
> 
> 
> > [    0.000000] Linux version 4.15.0-rc3-next-20171215-00001-g6d6aea478fce (avagin@laptop) (gcc version 7.2.1 20170915 (Red Hat 7.2.1-2) (GCC)) #11 SMP Fri Dec 15 16:39:11 PST 2017
> > [    0.000000] Command line: root=/dev/vda2 ro debug console=ttyS0,115200 LANG=en_US.UTF-8 slub_debug=FZP raid=noautodetect selinux=0
> > [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
> > [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
> > [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
> > [    0.000000] x86/fpu: Supporting XSAVE feature 0x008: 'MPX bounds registers'
> > [    0.000000] x86/fpu: Supporting XSAVE feature 0x010: 'MPX CSR'
> > [    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
> > [    0.000000] x86/fpu: xstate_offset[3]:  832, xstate_sizes[3]:   64
> > [    0.000000] x86/fpu: xstate_offset[4]:  896, xstate_sizes[4]:   64
> > [    0.000000] x86/fpu: Enabled xstate features 0x1f, context size is 960 bytes, using 'compacted' format.
> > [    0.000000] e820: BIOS-provided physical RAM map:
> > [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> > [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> > [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> > [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007ffd8fff] usable
> > [    0.000000] BIOS-e820: [mem 0x000000007ffd9000-0x000000007fffffff] reserved
> > [    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> > [    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> > [    0.000000] NX (Execute Disable) protection: active
> > [    0.000000] random: fast init done
> > [    0.000000] SMBIOS 2.8 present.
> > [    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
> > [    0.000000] Hypervisor detected: KVM
> > [    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> > [    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
> > [    0.000000] e820: last_pfn = 0x7ffd9 max_arch_pfn = 0x400000000
> > [    0.000000] MTRR default type: write-back
> > [    0.000000] MTRR fixed ranges enabled:
> > [    0.000000]   00000-9FFFF write-back
> > [    0.000000]   A0000-BFFFF uncachable
> > [    0.000000]   C0000-FFFFF write-protect
> > [    0.000000] MTRR variable ranges enabled:
> > [    0.000000]   0 base 0080000000 mask FF80000000 uncachable
> > [    0.000000]   1 disabled
> > [    0.000000]   2 disabled
> > [    0.000000]   3 disabled
> > [    0.000000]   4 disabled
> > [    0.000000]   5 disabled
> > [    0.000000]   6 disabled
> > [    0.000000]   7 disabled
> > [    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
> > [    0.000000] found SMP MP-table at [mem 0x000f6bd0-0x000f6bdf] mapped at [        (ptrval)]
> > [    0.000000] Base memory trampoline at [        (ptrval)] 99000 size 24576
> > [    0.000000] Using GB pages for direct mapping
> > [    0.000000] BRK [0x2c984000, 0x2c984fff] PGTABLE
> > [    0.000000] BRK [0x2c985000, 0x2c985fff] PGTABLE
> > [    0.000000] BRK [0x2c986000, 0x2c986fff] PGTABLE
> > [    0.000000] BRK [0x2c987000, 0x2c987fff] PGTABLE
> > [    0.000000] BRK [0x2c988000, 0x2c988fff] PGTABLE
> > [    0.000000] BRK [0x2c989000, 0x2c989fff] PGTABLE
> > [    0.000000] ACPI: Early table checksum verification disabled
> > [    0.000000] ACPI: RSDP 0x00000000000F69C0 000014 (v00 BOCHS )
> > [    0.000000] ACPI: RSDT 0x000000007FFE12FF 00002C (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
> > [    0.000000] ACPI: FACP 0x000000007FFE120B 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
> > [    0.000000] ACPI: DSDT 0x000000007FFE0040 0011CB (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
> > [    0.000000] ACPI: FACS 0x000000007FFE0000 000040
> > [    0.000000] ACPI: APIC 0x000000007FFE127F 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
> > [    0.000000] ACPI: Local APIC address 0xfee00000
> > [    0.000000] No NUMA configuration found
> > [    0.000000] Faking a node at [mem 0x0000000000000000-0x000000007ffd8fff]
> > [    0.000000] NODE_DATA(0) allocated [mem 0x7ffc2000-0x7ffd8fff]
> > [    0.000000] kvm-clock: cpu 0, msr 0:7ffc0001, primary cpu clock
> > [    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
> > [    0.000000] kvm-clock: using sched offset of 1076013277 cycles
> > [    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
> > [    0.000000] Zone ranges:
> > [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> > [    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffd8fff]
> > [    0.000000]   Normal   empty
> > [    0.000000]   Device   empty
> > [    0.000000] Movable zone start for each node
> > [    0.000000] Early memory node ranges
> > [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> > [    0.000000]   node   0: [mem 0x0000000000100000-0x000000007ffd8fff]
> > [    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007ffd8fff]
> > [    0.000000] On node 0 totalpages: 524151
> > [    0.000000]   DMA zone: 64 pages used for memmap
> > [    0.000000]   DMA zone: 21 pages reserved
> > [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> > [    0.000000]   DMA32 zone: 8128 pages used for memmap
> > [    0.000000]   DMA32 zone: 520153 pages, LIFO batch:31
> > [    0.000000] Reserved but unavailable: 98 pages
> > [    0.000000] ACPI: PM-Timer IO Port: 0x608
> > [    0.000000] ACPI: Local APIC address 0xfee00000
> > [    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
> > [    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
> > [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> > [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
> > [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> > [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
> > [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
> > [    0.000000] ACPI: IRQ0 used by override.
> > [    0.000000] ACPI: IRQ5 used by override.
> > [    0.000000] ACPI: IRQ9 used by override.
> > [    0.000000] ACPI: IRQ10 used by override.
> > [    0.000000] ACPI: IRQ11 used by override.
> > [    0.000000] Using ACPI (MADT) for SMP configuration information
> > [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
> > [    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> > [    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
> > [    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
> > [    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
> > [    0.000000] e820: [mem 0x80000000-0xfeffbfff] available for PCI devices
> > [    0.000000] Booting paravirtualized kernel on KVM
> > [    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
> > [    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:2 nr_node_ids:1
> > [    0.000000] percpu: Embedded 44 pages/cpu @        (ptrval) s142296 r8192 d29736 u1048576
> > [    0.000000] pcpu-alloc: s142296 r8192 d29736 u1048576 alloc=1*2097152
> > [    0.000000] pcpu-alloc: [0] 0 1 
> > [    0.000000] KVM setup async PF for cpu 0
> > [    0.000000] kvm-stealtime: cpu 0, msr 7fc122c0
> > [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 515938
> > [    0.000000] Policy zone: DMA32
> > [    0.000000] Kernel command line: root=/dev/vda2 ro debug console=ttyS0,115200 LANG=en_US.UTF-8 slub_debug=FZP raid=noautodetect selinux=0
> > [    0.000000] Memory: 2037056K/2096604K available (12300K kernel code, 1554K rwdata, 3584K rodata, 1640K init, 912K bss, 59548K reserved, 0K cma-reserved)
> > [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> > [    0.000000] ftrace: allocating 36554 entries in 143 pages
> > [    0.001000] Hierarchical RCU implementation.
> > [    0.001000] 	RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=2.
> > [    0.001000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=2
> > [    0.001000] NR_IRQS: 4352, nr_irqs: 440, preallocated irqs: 16
> > [    0.001000] 	Offload RCU callbacks from CPUs: (none).
> > [    0.001000] Console: colour dummy device 80x25
> > [    0.001000] console [ttyS0] enabled
> > [    0.001000] ACPI: Core revision 20171110
> > [    0.001000] ACPI: 1 ACPI AML tables successfully acquired and loaded
> > [    0.001009] APIC: Switch to symmetric I/O mode setup
> > [    0.001571] x2apic enabled
> > [    0.002003] Switched APIC routing to physical x2apic.
> > [    0.003538] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> > [    0.004000] tsc: Detected 2496.000 MHz processor
> > [    0.004014] Calibrating delay loop (skipped) preset value.. 4992.00 BogoMIPS (lpj=2496000)
> > [    0.005014] pid_max: default: 32768 minimum: 301
> > [    0.006057] Security Framework initialized
> > [    0.006548] Yama: becoming mindful.
> > [    0.007019] SELinux:  Disabled at boot.
> > [    0.008206] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
> > [    0.009164] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
> > [    0.009816] Mount-cache hash table entries: 4096 (order: 3, 32768 bytes)
> > [    0.010009] Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes)
> > [    0.011322] mce: CPU supports 10 MCE banks
> > [    0.011740] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> > [    0.012002] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> > [    0.012610] Freeing SMP alternatives memory: 36K
> > [    0.013467] TSC deadline timer enabled
> > [    0.013820] smpboot: CPU0: Intel Core Processor (Skylake) (family: 0x6, model: 0x5e, stepping: 0x3)
> > [    0.014000] Performance Events: unsupported p6 CPU model 94 no PMU driver, software events only.
> > [    0.014041] Hierarchical SRCU implementation.
> > [    0.015133] NMI watchdog: Perf event create on CPU 0 failed with -2
> > [    0.015725] NMI watchdog: Perf NMI watchdog permanently disabled
> > [    0.016077] smp: Bringing up secondary CPUs ...
> > [    0.016654] x86: Booting SMP configuration:
> > [    0.017005] .... node  #0, CPUs:      #1
> > [    0.001000] kvm-clock: cpu 1, msr 0:7ffc0041, secondary cpu clock
> > [    0.019051] KVM setup async PF for cpu 1
> > [    0.019599] kvm-stealtime: cpu 1, msr 7fd122c0
> > [    0.020009] smp: Brought up 1 node, 2 CPUs
> > [    0.020531] smpboot: Max logical packages: 2
> > [    0.021009] smpboot: Total of 2 processors activated (9984.00 BogoMIPS)
> > [    0.023160] devtmpfs: initialized
> > [    0.023513] x86/mm: Memory block size: 128MB
> > [    0.024811] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
> > [    0.025015] futex hash table entries: 512 (order: 3, 32768 bytes)
> > [    0.026185] RTC time:  0:42:06, date: 12/16/17
> > [    0.026790] NET: Registered protocol family 16
> > [    0.027204] audit: initializing netlink subsys (disabled)
> > [    0.027914] audit: type=2000 audit(1513384927.133:1): state=initialized audit_enabled=0 res=1
> > [    0.028185] cpuidle: using governor menu
> > [    0.029118] ACPI: bus type PCI registered
> > [    0.029872] PCI: Using configuration type 1 for base access
> > [    0.034355] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
> > [    0.035011] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
> > [    0.036066] cryptd: max_cpu_qlen set to 1000
> > [    0.036579] ACPI: Added _OSI(Module Device)
> > [    0.037007] ACPI: Added _OSI(Processor Device)
> > [    0.037426] ACPI: Added _OSI(3.0 _SCP Extensions)
> > [    0.037857] ACPI: Added _OSI(Processor Aggregator Device)
> > [    0.041356] ACPI: Interpreter enabled
> > [    0.041764] ACPI: (supports S0 S5)
> > [    0.042005] ACPI: Using IOAPIC for interrupt routing
> > [    0.042655] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> > [    0.043625] ACPI: Enabled 2 GPEs in block 00 to 0F
> > [    0.059248] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> > [    0.059953] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI]
> > [    0.060045] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
> > [    0.061180] PCI host bridge to bus 0000:00
> > [    0.061874] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
> > [    0.062013] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
> > [    0.063016] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
> > [    0.064015] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebfffff window]
> > [    0.065014] pci_bus 0000:00: root bus resource [bus 00-ff]
> > [    0.065753] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> > [    0.066487] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> > [    0.067537] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> > [    0.071700] pci 0000:00:01.1: reg 0x20: [io  0xc100-0xc10f]
> > [    0.074032] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
> > [    0.074908] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> > [    0.075011] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
> > [    0.076010] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> > [    0.077121] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> > [    0.078148] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
> > [    0.079014] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
> > [    0.080224] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
> > [    0.082007] pci 0000:00:03.0: reg 0x10: [io  0xc040-0xc05f]
> > [    0.083814] pci 0000:00:03.0: reg 0x14: [mem 0xfebc0000-0xfebc0fff]
> > [    0.089891] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
> > [    0.090545] pci 0000:00:05.0: [1af4:1003] type 00 class 0x078000
> > [    0.092708] pci 0000:00:05.0: reg 0x10: [io  0xc060-0xc07f]
> > [    0.094009] pci 0000:00:05.0: reg 0x14: [mem 0xfebc1000-0xfebc1fff]
> > [    0.102484] pci 0000:00:06.0: [8086:2934] type 00 class 0x0c0300
> > [    0.108028] pci 0000:00:06.0: reg 0x20: [io  0xc080-0xc09f]
> > [    0.110738] pci 0000:00:06.1: [8086:2935] type 00 class 0x0c0300
> > [    0.114388] pci 0000:00:06.1: reg 0x20: [io  0xc0a0-0xc0bf]
> > [    0.117339] pci 0000:00:06.2: [8086:2936] type 00 class 0x0c0300
> > [    0.122770] pci 0000:00:06.2: reg 0x20: [io  0xc0c0-0xc0df]
> > [    0.124738] pci 0000:00:06.7: [8086:293a] type 00 class 0x0c0320
> > [    0.125825] pci 0000:00:06.7: reg 0x10: [mem 0xfebc2000-0xfebc2fff]
> > [    0.130347] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
> > [    0.133007] pci 0000:00:07.0: reg 0x10: [io  0xc000-0xc03f]
> > [    0.134793] pci 0000:00:07.0: reg 0x14: [mem 0xfebc3000-0xfebc3fff]
> > [    0.141808] pci 0000:00:08.0: [1af4:1002] type 00 class 0x00ff00
> > [    0.142914] pci 0000:00:08.0: reg 0x10: [io  0xc0e0-0xc0ff]
> > [    0.148977] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
> > [    0.149455] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
> > [    0.150390] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
> > [    0.151382] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
> > [    0.152380] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
> > [    0.154508] vgaarb: loaded
> > [    0.155271] SCSI subsystem initialized
> > [    0.155887] EDAC MC: Ver: 3.0.0
> > [    0.156255] PCI: Using ACPI for IRQ routing
> > [    0.156566] PCI: pci_cache_line_size set to 64 bytes
> > [    0.157161] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> > [    0.157914] e820: reserve RAM buffer [mem 0x7ffd9000-0x7fffffff]
> > [    0.158253] NetLabel: Initializing
> > [    0.158765] NetLabel:  domain hash size = 128
> > [    0.159005] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
> > [    0.159775] NetLabel:  unlabeled traffic allowed by default
> > [    0.160073] clocksource: Switched to clocksource kvm-clock
> > [    0.186764] VFS: Disk quotas dquot_6.6.0
> > [    0.187277] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> > [    0.188251] FS-Cache: Loaded
> > [    0.188725] pnp: PnP ACPI init
> > [    0.189271] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
> > [    0.190231] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
> > [    0.191229] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
> > [    0.192096] pnp 00:03: [dma 2]
> > [    0.192514] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
> > [    0.193631] pnp 00:04: Plug and Play ACPI device, IDs PNP0501 (active)
> > [    0.195416] pnp: PnP ACPI: found 5 devices
> > [    0.206055] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
> > [    0.207127] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
> > [    0.207832] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
> > [    0.208594] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
> > [    0.209469] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff window]
> > [    0.210493] NET: Registered protocol family 2
> > [    0.211244] tcp_listen_portaddr_hash hash table entries: 1024 (order: 2, 16384 bytes)
> > [    0.212283] TCP established hash table entries: 16384 (order: 5, 131072 bytes)
> > [    0.213285] TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
> > [    0.214306] TCP: Hash tables configured (established 16384 bind 16384)
> > [    0.215065] UDP hash table entries: 1024 (order: 3, 32768 bytes)
> > [    0.215797] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
> > [    0.217934] NET: Registered protocol family 1
> > [    0.219126] RPC: Registered named UNIX socket transport module.
> > [    0.219676] RPC: Registered udp transport module.
> > [    0.220130] RPC: Registered tcp transport module.
> > [    0.220552] RPC: Registered tcp NFSv4.1 backchannel transport module.
> > [    0.221153] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
> > [    0.221701] pci 0000:00:01.0: PIIX3: Enabling Passive Release
> > [    0.222319] pci 0000:00:01.0: Activating ISA DMA hang workarounds
> > [    0.444214] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
> > [    0.880141] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
> > [    1.311493] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
> > [    1.748829] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
> > [    1.962124] PCI: CLS 0 bytes, default 64
> > [    1.964749] Initialise system trusted keyrings
> > [    1.965289] workingset: timestamp_bits=37 max_order=19 bucket_order=0
> > [    1.969600] zbud: loaded
> > [    1.971287] SGI XFS with security attributes, no debug enabled
> > [    2.106071] NET: Registered protocol family 38
> > [    2.106556] Key type asymmetric registered
> > [    2.106931] Asymmetric key parser 'x509' registered
> > [    2.107514] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
> > [    2.108327] io scheduler noop registered
> > [    2.108813] io scheduler deadline registered
> > [    2.109608] io scheduler cfq registered (default)
> > [    2.110258] io scheduler mq-deadline registered
> > [    2.110796] io scheduler kyber registered
> > [    2.111688] intel_idle: Please enable MWAIT in BIOS SETUP
> > [    2.112310] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
> > [    2.113037] ACPI: Power Button [PWRF]
> > [    2.331642] virtio-pci 0000:00:03.0: virtio_pci: leaving for legacy driver
> > [    2.554093] virtio-pci 0000:00:05.0: virtio_pci: leaving for legacy driver
> > [    2.775938] virtio-pci 0000:00:07.0: virtio_pci: leaving for legacy driver
> > [    2.975053] tsc: Refined TSC clocksource calibration: 2495.981 MHz
> > [    2.975641] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x23fa6529869, max_idle_ns: 440795218057 ns
> > [    3.029409] virtio-pci 0000:00:08.0: virtio_pci: leaving for legacy driver
> > [    3.032925] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
> > [    3.056849] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> > [    3.064748] Non-volatile memory driver v1.3
> > [    3.065925] ppdev: user-space parallel port driver
> > [    3.071816] loop: module loaded
> > [    3.075337]  vda: vda1 vda2 vda3
> > [    3.076659] Rounding down aligned max_sectors from 4294967295 to 4294967288
> > [    3.077996] Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
> > [    3.079790] libphy: Fixed MDIO Bus: probed
> > [    3.080257] tun: Universal TUN/TAP device driver, 1.6
> > [    3.082222] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
> > [    3.083675] serio: i8042 KBD port at 0x60,0x64 irq 1
> > [    3.084160] serio: i8042 AUX port at 0x60,0x64 irq 12
> > [    3.084816] mousedev: PS/2 mouse device common for all mice
> > [    3.086603] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
> > [    3.089192] rtc_cmos 00:00: RTC can wake from S4
> > [    3.090116] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
> > [    3.092829] rtc_cmos 00:00: alarms up to one day, y3k, 114 bytes nvram
> > [    3.093937] IR NEC protocol handler initialized
> > [    3.094408] IR RC5(x/sz) protocol handler initialized
> > [    3.094901] IR RC6 protocol handler initialized
> > [    3.095510] IR JVC protocol handler initialized
> > [    3.095952] IR Sony protocol handler initialized
> > [    3.096399] IR SANYO protocol handler initialized
> > [    3.096862] IR Sharp protocol handler initialized
> > [    3.097342] IR MCE Keyboard/mouse protocol handler initialized
> > [    3.097919] IR XMP protocol handler initialized
> > [    3.098530] device-mapper: uevent: version 1.0.3
> > [    3.099209] device-mapper: ioctl: 4.37.0-ioctl (2017-09-20) initialised: dm-devel@redhat.com
> > [    3.100398] device-mapper: multipath round-robin: version 1.2.0 loaded
> > [    3.101883] drop_monitor: Initializing network drop monitor service
> > [    3.102553] Netfilter messages via NETLINK v0.30.
> > [    3.103090] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> > [    3.103738] ctnetlink v0.93: registering with nfnetlink.
> > [    3.104494] ip_tables: (C) 2000-2006 Netfilter Core Team
> > [    3.105734] Initializing XFRM netlink socket
> > [    3.106885] NET: Registered protocol family 10
> > [    3.109341] Segment Routing with IPv6
> > [    3.109976] mip6: Mobile IPv6
> > [    3.111987] ip6_tables: (C) 2000-2006 Netfilter Core Team
> > [    3.114230] NET: Registered protocol family 17
> > [    3.115047] Bridge firewalling registered
> > [    3.115824] Ebtables v2.0 registered
> > [    3.117996] 8021q: 802.1Q VLAN Support v1.8
> > [    3.119429] AVX2 version of gcm_enc/dec engaged.
> > [    3.119886] AES CTR mode by8 optimization enabled
> > [    3.128818] sched_clock: Marking stable (3128714579, 0)->(3404180881, -275466302)
> > [    3.129945] registered taskstats version 1
> > [    3.130427] Loading compiled-in X.509 certificates
> > [    3.163216] Loaded X.509 cert 'Build time autogenerated kernel key: 38e0adea1af8bd8a23b02436d4acf2f8c7408d23'
> > [    3.166359] zswap: loaded using pool lzo/zbud
> > [    3.167943] Key type big_key registered
> > [    3.168778]   Magic number: 13:918:708
> > [    3.169255] rtc_cmos 00:00: setting system clock to 2017-12-16 00:42:09 UTC (1513384929)
> > [    3.170604] md: Skipping autodetection of RAID arrays. (raid=autodetect will force)
> > [    3.171932] EXT4-fs (vda2): couldn't mount as ext3 due to feature incompatibilities
> > [    3.173871] EXT4-fs (vda2): couldn't mount as ext2 due to feature incompatibilities
> > [    3.175306] EXT4-fs (vda2): INFO: recovery required on readonly filesystem
> > [    3.176212] EXT4-fs (vda2): write access will be enabled during recovery
> > [    3.397187] EXT4-fs (vda2): orphan cleanup on readonly fs
> > [    3.399412] EXT4-fs (vda2): 5 orphan inodes deleted
> > [    3.402759] EXT4-fs (vda2): recovery complete
> > [    3.466647] EXT4-fs (vda2): mounted filesystem with ordered data mode. Opts: (null)
> > [    3.469401] VFS: Mounted root (ext4 filesystem) readonly on device 253:2.
> > [    3.473719] devtmpfs: mounted
> > [    3.492549] Freeing unused kernel memory: 1640K
> > [    3.494547] Write protecting the kernel read-only data: 18432k
> > [    3.498781] Freeing unused kernel memory: 2016K
> > [    3.503330] Freeing unused kernel memory: 512K
> > [    3.505232] rodata_test: all tests were successful
> > [    3.515355] 1 (init): Uhuuh, elf segement at 00000000928fda3e requested but the memory is mapped already
> > [    3.519533] Starting init: /sbin/init exists but couldn't execute it (error -95)
> > [    3.528993] Starting init: /bin/sh exists but couldn't execute it (error -14)
> > [    3.532127] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
> > [    3.538328] CPU: 0 PID: 1 Comm: init Not tainted 4.15.0-rc3-next-20171215-00001-g6d6aea478fce #11
> > [    3.542201] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
> > [    3.546081] Call Trace:
> > [    3.547221]  dump_stack+0x5c/0x79
> > [    3.548768]  ? rest_init+0x30/0xb0
> > [    3.550320]  panic+0xe4/0x232
> > [    3.551669]  ? rest_init+0xb0/0xb0
> > [    3.553110]  kernel_init+0xeb/0x100
> > [    3.554701]  ret_from_fork+0x1f/0x30
> > [    3.558964] Kernel Offset: 0x2000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> > [    3.564160] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
> 
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
