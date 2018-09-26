Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 561988E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 05:38:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g11-v6so950686edi.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 02:38:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si7691549edv.104.2018.09.26.02.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 02:38:22 -0700 (PDT)
Date: Wed, 26 Sep 2018 11:38:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 21/30] memblock: replace alloc_bootmem with memblock_alloc
Message-ID: <20180926093820.GR6278@dhcp22.suse.cz>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536927045-23536-22-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536927045-23536-22-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp

On Fri 14-09-18 15:10:36, Mike Rapoport wrote:
> The alloc_bootmem(size) is a shortcut for allocation of SMP_CACHE_BYTES
> aligned memory. When the align parameter of memblock_alloc() is 0, the
> alignment is implicitly set to SMP_CACHE_BYTES and thus alloc_bootmem(size)
> and memblock_alloc(size, 0) are equivalent.
> 
> The conversion is done using the following semantic patch:
> 
> @@
> expression size;
> @@
> - alloc_bootmem(size)
> + memblock_alloc(size, 0)

As mentioned in other email, please make it explicit SMP_CACHE_BYTES.

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  arch/alpha/kernel/core_marvel.c     | 4 ++--
>  arch/alpha/kernel/pci-noop.c        | 4 ++--
>  arch/alpha/kernel/pci.c             | 4 ++--
>  arch/alpha/kernel/pci_iommu.c       | 4 ++--
>  arch/ia64/kernel/mca.c              | 4 ++--
>  arch/ia64/mm/tlb.c                  | 4 ++--
>  arch/m68k/sun3/sun3dvma.c           | 3 ++-
>  arch/microblaze/mm/init.c           | 2 +-
>  arch/mips/kernel/setup.c            | 2 +-
>  arch/um/drivers/net_kern.c          | 2 +-
>  arch/um/drivers/vector_kern.c       | 2 +-
>  arch/um/kernel/initrd.c             | 2 +-
>  arch/x86/kernel/acpi/boot.c         | 3 ++-
>  arch/x86/kernel/apic/io_apic.c      | 2 +-
>  arch/x86/kernel/e820.c              | 2 +-
>  arch/x86/platform/olpc/olpc_dt.c    | 2 +-
>  arch/xtensa/platforms/iss/network.c | 2 +-
>  drivers/macintosh/smu.c             | 2 +-
>  init/main.c                         | 4 ++--
>  19 files changed, 28 insertions(+), 26 deletions(-)
> 
> diff --git a/arch/alpha/kernel/core_marvel.c b/arch/alpha/kernel/core_marvel.c
> index bdebb8c2..1f00c94 100644
> --- a/arch/alpha/kernel/core_marvel.c
> +++ b/arch/alpha/kernel/core_marvel.c
> @@ -82,7 +82,7 @@ mk_resource_name(int pe, int port, char *str)
>  	char *name;
>  	
>  	sprintf(tmp, "PCI %s PE %d PORT %d", str, pe, port);
> -	name = alloc_bootmem(strlen(tmp) + 1);
> +	name = memblock_alloc(strlen(tmp) + 1, 0);
>  	strcpy(name, tmp);
>  
>  	return name;
> @@ -117,7 +117,7 @@ alloc_io7(unsigned int pe)
>  		return NULL;
>  	}
>  
> -	io7 = alloc_bootmem(sizeof(*io7));
> +	io7 = memblock_alloc(sizeof(*io7), 0);
>  	io7->pe = pe;
>  	raw_spin_lock_init(&io7->irq_lock);
>  
> diff --git a/arch/alpha/kernel/pci-noop.c b/arch/alpha/kernel/pci-noop.c
> index c7c5879..59cbfc2 100644
> --- a/arch/alpha/kernel/pci-noop.c
> +++ b/arch/alpha/kernel/pci-noop.c
> @@ -33,7 +33,7 @@ alloc_pci_controller(void)
>  {
>  	struct pci_controller *hose;
>  
> -	hose = alloc_bootmem(sizeof(*hose));
> +	hose = memblock_alloc(sizeof(*hose), 0);
>  
>  	*hose_tail = hose;
>  	hose_tail = &hose->next;
> @@ -44,7 +44,7 @@ alloc_pci_controller(void)
>  struct resource * __init
>  alloc_resource(void)
>  {
> -	return alloc_bootmem(sizeof(struct resource));
> +	return memblock_alloc(sizeof(struct resource), 0);
>  }
>  
>  SYSCALL_DEFINE3(pciconfig_iobase, long, which, unsigned long, bus,
> diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
> index c668c3b..4cc3eb9 100644
> --- a/arch/alpha/kernel/pci.c
> +++ b/arch/alpha/kernel/pci.c
> @@ -392,7 +392,7 @@ alloc_pci_controller(void)
>  {
>  	struct pci_controller *hose;
>  
> -	hose = alloc_bootmem(sizeof(*hose));
> +	hose = memblock_alloc(sizeof(*hose), 0);
>  
>  	*hose_tail = hose;
>  	hose_tail = &hose->next;
> @@ -403,7 +403,7 @@ alloc_pci_controller(void)
>  struct resource * __init
>  alloc_resource(void)
>  {
> -	return alloc_bootmem(sizeof(struct resource));
> +	return memblock_alloc(sizeof(struct resource), 0);
>  }
>  
>  
> diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
> index 0c05493..5d178c7 100644
> --- a/arch/alpha/kernel/pci_iommu.c
> +++ b/arch/alpha/kernel/pci_iommu.c
> @@ -79,7 +79,7 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
>  		printk("%s: couldn't allocate arena from node %d\n"
>  		       "    falling back to system-wide allocation\n",
>  		       __func__, nid);
> -		arena = alloc_bootmem(sizeof(*arena));
> +		arena = memblock_alloc(sizeof(*arena), 0);
>  	}
>  
>  	arena->ptes = memblock_alloc_node(sizeof(*arena), align, nid);
> @@ -92,7 +92,7 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
>  
>  #else /* CONFIG_DISCONTIGMEM */
>  
> -	arena = alloc_bootmem(sizeof(*arena));
> +	arena = memblock_alloc(sizeof(*arena), 0);
>  	arena->ptes = memblock_alloc_from(mem_size, align, 0);
>  
>  #endif /* CONFIG_DISCONTIGMEM */
> diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
> index 5586926..7120976 100644
> --- a/arch/ia64/kernel/mca.c
> +++ b/arch/ia64/kernel/mca.c
> @@ -361,9 +361,9 @@ static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
>  
>  #define IA64_LOG_ALLOCATE(it, size) \
>  	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
> -		(ia64_err_rec_t *)alloc_bootmem(size); \
> +		(ia64_err_rec_t *)memblock_alloc(size, 0); \
>  	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
> -		(ia64_err_rec_t *)alloc_bootmem(size);}
> +		(ia64_err_rec_t *)memblock_alloc(size, 0);}
>  #define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
>  #define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
>  #define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
> diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
> index acf10eb..5554863 100644
> --- a/arch/ia64/mm/tlb.c
> +++ b/arch/ia64/mm/tlb.c
> @@ -59,8 +59,8 @@ struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
>  void __init
>  mmu_context_init (void)
>  {
> -	ia64_ctx.bitmap = alloc_bootmem((ia64_ctx.max_ctx+1)>>3);
> -	ia64_ctx.flushmap = alloc_bootmem((ia64_ctx.max_ctx+1)>>3);
> +	ia64_ctx.bitmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3, 0);
> +	ia64_ctx.flushmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3, 0);
>  }
>  
>  /*
> diff --git a/arch/m68k/sun3/sun3dvma.c b/arch/m68k/sun3/sun3dvma.c
> index 8546922..72d9458 100644
> --- a/arch/m68k/sun3/sun3dvma.c
> +++ b/arch/m68k/sun3/sun3dvma.c
> @@ -267,7 +267,8 @@ void __init dvma_init(void)
>  
>  	list_add(&(hole->list), &hole_list);
>  
> -	iommu_use = alloc_bootmem(IOMMU_TOTAL_ENTRIES * sizeof(unsigned long));
> +	iommu_use = memblock_alloc(IOMMU_TOTAL_ENTRIES * sizeof(unsigned long),
> +				   0);
>  
>  	dvma_unmap_iommu(DVMA_START, DVMA_SIZE);
>  
> diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> index df6de7c..8c7f074 100644
> --- a/arch/microblaze/mm/init.c
> +++ b/arch/microblaze/mm/init.c
> @@ -377,7 +377,7 @@ void * __ref zalloc_maybe_bootmem(size_t size, gfp_t mask)
>  	if (mem_init_done)
>  		p = kzalloc(size, mask);
>  	else {
> -		p = alloc_bootmem(size);
> +		p = memblock_alloc(size, 0);
>  		if (p)
>  			memset(p, 0, size);
>  	}
> diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> index a717c90..a6bc2f6 100644
> --- a/arch/mips/kernel/setup.c
> +++ b/arch/mips/kernel/setup.c
> @@ -909,7 +909,7 @@ static void __init resource_init(void)
>  		if (end >= HIGHMEM_START)
>  			end = HIGHMEM_START - 1;
>  
> -		res = alloc_bootmem(sizeof(struct resource));
> +		res = memblock_alloc(sizeof(struct resource), 0);
>  
>  		res->start = start;
>  		res->end = end;
> diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
> index 3ef1b48..ef19a39 100644
> --- a/arch/um/drivers/net_kern.c
> +++ b/arch/um/drivers/net_kern.c
> @@ -650,7 +650,7 @@ static int __init eth_setup(char *str)
>  		return 1;
>  	}
>  
> -	new = alloc_bootmem(sizeof(*new));
> +	new = memblock_alloc(sizeof(*new), 0);
>  
>  	INIT_LIST_HEAD(&new->list);
>  	new->index = n;
> diff --git a/arch/um/drivers/vector_kern.c b/arch/um/drivers/vector_kern.c
> index c84133c..9d77579 100644
> --- a/arch/um/drivers/vector_kern.c
> +++ b/arch/um/drivers/vector_kern.c
> @@ -1575,7 +1575,7 @@ static int __init vector_setup(char *str)
>  				 str, error);
>  		return 1;
>  	}
> -	new = alloc_bootmem(sizeof(*new));
> +	new = memblock_alloc(sizeof(*new), 0);
>  	INIT_LIST_HEAD(&new->list);
>  	new->unit = n;
>  	new->arguments = str;
> diff --git a/arch/um/kernel/initrd.c b/arch/um/kernel/initrd.c
> index 6f6e789..844056c 100644
> --- a/arch/um/kernel/initrd.c
> +++ b/arch/um/kernel/initrd.c
> @@ -36,7 +36,7 @@ int __init read_initrd(void)
>  		return 0;
>  	}
>  
> -	area = alloc_bootmem(size);
> +	area = memblock_alloc(size, 0);
>  
>  	if (load_initrd(initrd, area, size) == -1)
>  		return 0;
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 3b20607..fd887c1 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -932,7 +932,8 @@ static int __init acpi_parse_hpet(struct acpi_table_header *table)
>  	 * the resource tree during the lateinit timeframe.
>  	 */
>  #define HPET_RESOURCE_NAME_SIZE 9
> -	hpet_res = alloc_bootmem(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
> +	hpet_res = memblock_alloc(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE,
> +				  0);
>  
>  	hpet_res->name = (void *)&hpet_res[1];
>  	hpet_res->flags = IORESOURCE_MEM;
> diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
> index e25118f..8c74509 100644
> --- a/arch/x86/kernel/apic/io_apic.c
> +++ b/arch/x86/kernel/apic/io_apic.c
> @@ -2578,7 +2578,7 @@ static struct resource * __init ioapic_setup_resources(void)
>  	n = IOAPIC_RESOURCE_NAME_SIZE + sizeof(struct resource);
>  	n *= nr_ioapics;
>  
> -	mem = alloc_bootmem(n);
> +	mem = memblock_alloc(n, 0);
>  	res = (void *)mem;
>  
>  	mem += sizeof(struct resource) * nr_ioapics;
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index c88c23c..7ea8748 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -1094,7 +1094,7 @@ void __init e820__reserve_resources(void)
>  	struct resource *res;
>  	u64 end;
>  
> -	res = alloc_bootmem(sizeof(*res) * e820_table->nr_entries);
> +	res = memblock_alloc(sizeof(*res) * e820_table->nr_entries, 0);
>  	e820_res = res;
>  
>  	for (i = 0; i < e820_table->nr_entries; i++) {
> diff --git a/arch/x86/platform/olpc/olpc_dt.c b/arch/x86/platform/olpc/olpc_dt.c
> index d6ee929..140cd76 100644
> --- a/arch/x86/platform/olpc/olpc_dt.c
> +++ b/arch/x86/platform/olpc/olpc_dt.c
> @@ -141,7 +141,7 @@ void * __init prom_early_alloc(unsigned long size)
>  		 * fast enough on the platforms we care about while minimizing
>  		 * wasted bootmem) and hand off chunks of it to callers.
>  		 */
> -		res = alloc_bootmem(chunk_size);
> +		res = memblock_alloc(chunk_size, 0);
>  		BUG_ON(!res);
>  		prom_early_allocated += chunk_size;
>  		memset(res, 0, chunk_size);
> diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
> index d027ddd..206b9d4 100644
> --- a/arch/xtensa/platforms/iss/network.c
> +++ b/arch/xtensa/platforms/iss/network.c
> @@ -646,7 +646,7 @@ static int __init iss_net_setup(char *str)
>  		return 1;
>  	}
>  
> -	new = alloc_bootmem(sizeof(*new));
> +	new = memblock_alloc(sizeof(*new), 0);
>  	if (new == NULL) {
>  		pr_err("Alloc_bootmem failed\n");
>  		return 1;
> diff --git a/drivers/macintosh/smu.c b/drivers/macintosh/smu.c
> index e8ae2e5..332fcca 100644
> --- a/drivers/macintosh/smu.c
> +++ b/drivers/macintosh/smu.c
> @@ -493,7 +493,7 @@ int __init smu_init (void)
>  		goto fail_np;
>  	}
>  
> -	smu = alloc_bootmem(sizeof(struct smu_device));
> +	smu = memblock_alloc(sizeof(struct smu_device), 0);
>  
>  	spin_lock_init(&smu->lock);
>  	INIT_LIST_HEAD(&smu->cmd_list);
> diff --git a/init/main.c b/init/main.c
> index d0b92bd..99a9e99 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -768,8 +768,8 @@ static int __init initcall_blacklist(char *str)
>  		str_entry = strsep(&str, ",");
>  		if (str_entry) {
>  			pr_debug("blacklisting initcall %s\n", str_entry);
> -			entry = alloc_bootmem(sizeof(*entry));
> -			entry->buf = alloc_bootmem(strlen(str_entry) + 1);
> +			entry = memblock_alloc(sizeof(*entry), 0);
> +			entry->buf = memblock_alloc(strlen(str_entry) + 1, 0);
>  			strcpy(entry->buf, str_entry);
>  			list_add(&entry->next, &blacklisted_initcalls);
>  		}
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
