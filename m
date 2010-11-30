Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B29556B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 22:48:51 -0500 (EST)
Subject: Re: [PATCH] mm: make ioremap_prot() take a pgprot.
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20101102203102.GA12723@linux-sh.org>
References: <20101102203102.GA12723@linux-sh.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 14:48:36 +1100
Message-ID: <1291088916.32570.352.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Metcalf <cmetcalf@tilera.com>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-03 at 05:31 +0900, Paul Mundt wrote:
> The current definition of ioremap_prot() takes an unsigned long for the
> page flags and then converts to/from a pgprot as necessary. This is
> unfortunately not sufficient for the SH-X2 TLB case which has a 64-bit
> pgprot and a 32-bit unsigned long.
> 
> An inspection of the tree shows that tile and cris also have their
> own equivalent routines that are using the pgprot_t but do not set
> HAVE_IOREMAP_PROT, both of which could trivially be adapted.
> 
> After cris/tile are updated there would also be enough critical mass to
> move the powerpc devm_ioremap_prot() in to the generic lib/devres.c.
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>

Finally got to this :-)

Looks good to me, compile test in progress and ... it passes.

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

> 
> ---
> 
>  arch/powerpc/include/asm/io.h       |    8 +++++---
>  arch/powerpc/lib/devres.c           |   10 +++++-----
>  arch/sh/Kconfig                     |    2 +-
>  arch/sh/boards/mach-landisk/setup.c |    2 +-
>  arch/sh/boards/mach-lboxre2/setup.c |    2 +-
>  arch/sh/boards/mach-sh03/setup.c    |    2 +-
>  arch/sh/include/asm/io.h            |    4 ++--
>  arch/x86/include/asm/io.h           |    2 +-
>  arch/x86/mm/ioremap.c               |    5 +++--
>  arch/x86/mm/pat.c                   |    5 ++---
>  include/linux/mm.h                  |    2 +-
>  mm/memory.c                         |    6 +++---
>  12 files changed, 26 insertions(+), 24 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/io.h b/arch/powerpc/include/asm/io.h
> index 001f2f1..27f40e6 100644
> --- a/arch/powerpc/include/asm/io.h
> +++ b/arch/powerpc/include/asm/io.h
> @@ -618,7 +618,8 @@ static inline void iosync(void)
>   *
>   * * ioremap_flags allows to specify the page flags as an argument and can
>   *   also be hooked by the platform via ppc_md. ioremap_prot is the exact
> - *   same thing as ioremap_flags.
> + *   same thing as ioremap_flags, with the exception that it takes a
> + *   pgprot value instead.
>   *
>   * * ioremap_nocache is identical to ioremap
>   *
> @@ -643,7 +644,8 @@ extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
>  extern void __iomem *ioremap_flags(phys_addr_t address, unsigned long size,
>  				   unsigned long flags);
>  #define ioremap_nocache(addr, size)	ioremap((addr), (size))
> -#define ioremap_prot(addr, size, prot)	ioremap_flags((addr), (size), (prot))
> +#define ioremap_prot(addr, size, prot)	ioremap_flags((addr), (size), \
> +						      pgprot_val(prot))
>  
>  extern void iounmap(volatile void __iomem *addr);
>  
> @@ -779,7 +781,7 @@ static inline void * bus_to_virt(unsigned long address)
>  #define clrsetbits_8(addr, clear, set) clrsetbits(8, addr, clear, set)
>  
>  void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
> -				size_t size, unsigned long flags);
> +				size_t size, pgprot_t prot);
>  
>  #endif /* __KERNEL__ */
>  
> diff --git a/arch/powerpc/lib/devres.c b/arch/powerpc/lib/devres.c
> index deac4d3..045f7a7 100644
> --- a/arch/powerpc/lib/devres.c
> +++ b/arch/powerpc/lib/devres.c
> @@ -9,21 +9,21 @@
>  
>  #include <linux/device.h>	/* devres_*(), devm_ioremap_release() */
>  #include <linux/gfp.h>
> -#include <linux/io.h>		/* ioremap_flags() */
> +#include <linux/io.h>		/* ioremap_prot() */
>  #include <linux/module.h>	/* EXPORT_SYMBOL() */
>  
>  /**
> - * devm_ioremap_prot - Managed ioremap_flags()
> + * devm_ioremap_prot - Managed ioremap_prot()
>   * @dev: Generic device to remap IO address for
>   * @offset: BUS offset to map
>   * @size: Size of map
> - * @flags: Page flags
> + * @prot: Page protection flags
>   *
>   * Managed ioremap_prot().  Map is automatically unmapped on driver
>   * detach.
>   */
>  void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
> -				 size_t size, unsigned long flags)
> +				 size_t size, pgprot_t prot)
>  {
>  	void __iomem **ptr, *addr;
>  
> @@ -31,7 +31,7 @@ void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
>  	if (!ptr)
>  		return NULL;
>  
> -	addr = ioremap_flags(offset, size, flags);
> +	addr = ioremap_prot(offset, size, prot);
>  	if (addr) {
>  		*ptr = addr;
>  		devres_add(dev, ptr);
> diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
> index 435e7f8..71ce972 100644
> --- a/arch/sh/Kconfig
> +++ b/arch/sh/Kconfig
> @@ -33,7 +33,7 @@ config SUPERH32
>  	def_bool ARCH = "sh"
>  	select HAVE_KPROBES
>  	select HAVE_KRETPROBES
> -	select HAVE_IOREMAP_PROT if MMU && !X2TLB
> +	select HAVE_IOREMAP_PROT if MMU
>  	select HAVE_FUNCTION_TRACER
>  	select HAVE_FTRACE_MCOUNT_RECORD
>  	select HAVE_DYNAMIC_FTRACE
> diff --git a/arch/sh/boards/mach-landisk/setup.c b/arch/sh/boards/mach-landisk/setup.c
> index 50337ac..94ab2bb 100644
> --- a/arch/sh/boards/mach-landisk/setup.c
> +++ b/arch/sh/boards/mach-landisk/setup.c
> @@ -63,7 +63,7 @@ static int __init landisk_devices_setup(void)
>  	/* open I/O area window */
>  	paddrbase = virt_to_phys((void *)PA_AREA5_IO);
>  	prot = PAGE_KERNEL_PCC(1, _PAGE_PCC_IO16);
> -	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, pgprot_val(prot));
> +	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, prot);
>  	if (!cf_ide_base) {
>  		printk("allocate_cf_area : can't open CF I/O window!\n");
>  		return -ENOMEM;
> diff --git a/arch/sh/boards/mach-lboxre2/setup.c b/arch/sh/boards/mach-lboxre2/setup.c
> index 79b4e0d..30e0eeb 100644
> --- a/arch/sh/boards/mach-lboxre2/setup.c
> +++ b/arch/sh/boards/mach-lboxre2/setup.c
> @@ -57,7 +57,7 @@ static int __init lboxre2_devices_setup(void)
>  	paddrbase = virt_to_phys((void*)PA_AREA5_IO);
>  	psize = PAGE_SIZE;
>  	prot = PAGE_KERNEL_PCC(1, _PAGE_PCC_IO16);
> -	cf0_io_base = (u32)ioremap_prot(paddrbase, psize, pgprot_val(prot));
> +	cf0_io_base = (u32)ioremap_prot(paddrbase, psize, prot);
>  	if (!cf0_io_base) {
>  		printk(KERN_ERR "%s : can't open CF I/O window!\n" , __func__ );
>  		return -ENOMEM;
> diff --git a/arch/sh/boards/mach-sh03/setup.c b/arch/sh/boards/mach-sh03/setup.c
> index af4a0c0..abfb782 100644
> --- a/arch/sh/boards/mach-sh03/setup.c
> +++ b/arch/sh/boards/mach-sh03/setup.c
> @@ -82,7 +82,7 @@ static int __init sh03_devices_setup(void)
>  	/* open I/O area window */
>  	paddrbase = virt_to_phys((void *)PA_AREA5_IO);
>  	prot = PAGE_KERNEL_PCC(1, _PAGE_PCC_IO16);
> -	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, pgprot_val(prot));
> +	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, prot);
>  	if (!cf_ide_base) {
>  		printk("allocate_cf_area : can't open CF I/O window!\n");
>  		return -ENOMEM;
> diff --git a/arch/sh/include/asm/io.h b/arch/sh/include/asm/io.h
> index 89ab2c5..e3f47f3 100644
> --- a/arch/sh/include/asm/io.h
> +++ b/arch/sh/include/asm/io.h
> @@ -389,9 +389,9 @@ ioremap_cache(phys_addr_t offset, unsigned long size)
>  
>  #ifdef CONFIG_HAVE_IOREMAP_PROT
>  static inline void __iomem *
> -ioremap_prot(phys_addr_t offset, unsigned long size, unsigned long flags)
> +ioremap_prot(phys_addr_t offset, unsigned long size, pgprot_t prot)
>  {
> -	return __ioremap_mode(offset, size, __pgprot(flags));
> +	return __ioremap_mode(offset, size, prot);
>  }
>  #endif
>  
> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
> index 0722730..e61c439 100644
> --- a/arch/x86/include/asm/io.h
> +++ b/arch/x86/include/asm/io.h
> @@ -196,7 +196,7 @@ static inline unsigned int isa_virt_to_bus(volatile void *address)
>  extern void __iomem *ioremap_nocache(resource_size_t offset, unsigned long size);
>  extern void __iomem *ioremap_cache(resource_size_t offset, unsigned long size);
>  extern void __iomem *ioremap_prot(resource_size_t offset, unsigned long size,
> -				unsigned long prot_val);
> +				pgprot_t prot);
>  
>  /*
>   * The default ioremap() behavior is non-cached:
> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> index 0369843..7e028ac 100644
> --- a/arch/x86/mm/ioremap.c
> +++ b/arch/x86/mm/ioremap.c
> @@ -243,9 +243,10 @@ void __iomem *ioremap_cache(resource_size_t phys_addr, unsigned long size)
>  EXPORT_SYMBOL(ioremap_cache);
>  
>  void __iomem *ioremap_prot(resource_size_t phys_addr, unsigned long size,
> -				unsigned long prot_val)
> +				pgprot_t prot)
>  {
> -	return __ioremap_caller(phys_addr, size, (prot_val & _PAGE_CACHE_MASK),
> +	return __ioremap_caller(phys_addr, size,
> +				(pgprot_val(prot) & _PAGE_CACHE_MASK),
>  				__builtin_return_address(0));
>  }
>  EXPORT_SYMBOL(ioremap_prot);
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index f6ff57b..56e8041 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -661,7 +661,6 @@ static void free_pfn_range(u64 paddr, unsigned long size)
>  int track_pfn_vma_copy(struct vm_area_struct *vma)
>  {
>  	resource_size_t paddr;
> -	unsigned long prot;
>  	unsigned long vma_size = vma->vm_end - vma->vm_start;
>  	pgprot_t pgprot;
>  
> @@ -670,11 +669,11 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
>  		 * reserve the whole chunk covered by vma. We need the
>  		 * starting address and protection from pte.
>  		 */
> -		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr)) {
> +		if (follow_phys(vma, vma->vm_start, 0, &pgprot, &paddr)) {
>  			WARN_ON_ONCE(1);
>  			return -EINVAL;
>  		}
> -		pgprot = __pgprot(prot);
> +
>  		return reserve_pfn_range(paddr, vma_size, &pgprot, 1);
>  	}
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 721f451..0f7d3a1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -818,7 +818,7 @@ void unmap_mapping_range(struct address_space *mapping,
>  int follow_pfn(struct vm_area_struct *vma, unsigned long address,
>  	unsigned long *pfn);
>  int follow_phys(struct vm_area_struct *vma, unsigned long address,
> -		unsigned int flags, unsigned long *prot, resource_size_t *phys);
> +		unsigned int flags, pgprot_t *prot, resource_size_t *phys);
>  int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
>  			void *buf, int len, int write);
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 02e48aa..598eee3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3431,7 +3431,7 @@ EXPORT_SYMBOL(follow_pfn);
>  #ifdef CONFIG_HAVE_IOREMAP_PROT
>  int follow_phys(struct vm_area_struct *vma,
>  		unsigned long address, unsigned int flags,
> -		unsigned long *prot, resource_size_t *phys)
> +		pgprot_t *prot, resource_size_t *phys)
>  {
>  	int ret = -EINVAL;
>  	pte_t *ptep, pte;
> @@ -3447,7 +3447,7 @@ int follow_phys(struct vm_area_struct *vma,
>  	if ((flags & FOLL_WRITE) && !pte_write(pte))
>  		goto unlock;
>  
> -	*prot = pgprot_val(pte_pgprot(pte));
> +	*prot = pte_pgprot(pte);
>  	*phys = (resource_size_t)pte_pfn(pte) << PAGE_SHIFT;
>  
>  	ret = 0;
> @@ -3461,7 +3461,7 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
>  			void *buf, int len, int write)
>  {
>  	resource_size_t phys_addr;
> -	unsigned long prot = 0;
> +	pgprot_t prot;
>  	void __iomem *maddr;
>  	int offset = addr & (PAGE_SIZE-1);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
