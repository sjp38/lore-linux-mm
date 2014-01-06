Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7256B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 18:15:11 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id lx4so19720365iec.9
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 15:15:11 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id uh4si406545igc.32.2014.01.06.15.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 15:15:10 -0800 (PST)
Message-ID: <1389050101.12906.13.camel@pasglop>
Subject: Re: [PATCH -V3 1/2] powerpc: mm: Move ppc64 page table range
 definitions to separate header
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Jan 2014 10:15:01 +1100
In-Reply-To: <1388999012-14424-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: 
	<1388999012-14424-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 2014-01-06 at 14:33 +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This avoid mmu-hash64.h including pagetable-ppc64.h. That inclusion
> cause issues like

I don't like this. We have that stuff split into too many includes
already it's a mess.

Why do we need to include it from mmu*.h ?

Cheers,
Ben.

>   CC      arch/powerpc/kernel/asm-offsets.s
> In file included from /home/aneesh/linus/arch/powerpc/include/asm/mmu-hash64.h:23:0,
>                  from /home/aneesh/linus/arch/powerpc/include/asm/mmu.h:196,
>                  from /home/aneesh/linus/arch/powerpc/include/asm/lppaca.h:36,
>                  from /home/aneesh/linus/arch/powerpc/include/asm/paca.h:21,
>                  from /home/aneesh/linus/arch/powerpc/include/asm/hw_irq.h:41,
>                  from /home/aneesh/linus/arch/powerpc/include/asm/irqflags.h:11,
>                  from include/linux/irqflags.h:15,
>                  from include/linux/spinlock.h:53,
>                  from include/linux/seqlock.h:35,
>                  from include/linux/time.h:5,
>                  from include/uapi/linux/timex.h:56,
>                  from include/linux/timex.h:56,
>                  from include/linux/sched.h:17,
>                  from arch/powerpc/kernel/asm-offsets.c:17:
> /home/aneesh/linus/arch/powerpc/include/asm/pgtable-ppc64.h:563:42: error: unknown type name a??spinlock_ta??
>  static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> 
> NOTE: We can either do this or stuck a typdef struct spinlock spinlock_t; in pgtable-ppc64.h 
> 
>  arch/powerpc/include/asm/mmu-hash64.h          |   2 +-
>  arch/powerpc/include/asm/pgtable-ppc64-range.h | 101 +++++++++++++++++++++++++
>  arch/powerpc/include/asm/pgtable-ppc64.h       | 101 +------------------------
>  3 files changed, 103 insertions(+), 101 deletions(-)
>  create mode 100644 arch/powerpc/include/asm/pgtable-ppc64-range.h
> 
> diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/mmu-hash64.h
> index 807014dde821..895b4df31fec 100644
> --- a/arch/powerpc/include/asm/mmu-hash64.h
> +++ b/arch/powerpc/include/asm/mmu-hash64.h
> @@ -20,7 +20,7 @@
>   * need for various slices related matters. Note that this isn't the
>   * complete pgtable.h but only a portion of it.
>   */
> -#include <asm/pgtable-ppc64.h>
> +#include <asm/pgtable-ppc64-range.h>
>  #include <asm/bug.h>
>  
>  /*
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64-range.h b/arch/powerpc/include/asm/pgtable-ppc64-range.h
> new file mode 100644
> index 000000000000..b48b089fb209
> --- /dev/null
> +++ b/arch/powerpc/include/asm/pgtable-ppc64-range.h
> @@ -0,0 +1,101 @@
> +#ifndef _ASM_POWERPC_PGTABLE_PPC64_RANGE_H_
> +#define _ASM_POWERPC_PGTABLE_PPC64_RANGE_H_
> +/*
> + * This file contains the functions and defines necessary to modify and use
> + * the ppc64 hashed page table.
> + */
> +
> +#ifdef CONFIG_PPC_64K_PAGES
> +#include <asm/pgtable-ppc64-64k.h>
> +#else
> +#include <asm/pgtable-ppc64-4k.h>
> +#endif
> +#include <asm/barrier.h>
> +
> +#define FIRST_USER_ADDRESS	0
> +
> +/*
> + * Size of EA range mapped by our pagetables.
> + */
> +#define PGTABLE_EADDR_SIZE (PTE_INDEX_SIZE + PMD_INDEX_SIZE + \
> +			    PUD_INDEX_SIZE + PGD_INDEX_SIZE + PAGE_SHIFT)
> +#define PGTABLE_RANGE (ASM_CONST(1) << PGTABLE_EADDR_SIZE)
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define PMD_CACHE_INDEX	(PMD_INDEX_SIZE + 1)
> +#else
> +#define PMD_CACHE_INDEX	PMD_INDEX_SIZE
> +#endif
> +/*
> + * Define the address range of the kernel non-linear virtual area
> + */
> +
> +#ifdef CONFIG_PPC_BOOK3E
> +#define KERN_VIRT_START ASM_CONST(0x8000000000000000)
> +#else
> +#define KERN_VIRT_START ASM_CONST(0xD000000000000000)
> +#endif
> +#define KERN_VIRT_SIZE	ASM_CONST(0x0000100000000000)
> +
> +/*
> + * The vmalloc space starts at the beginning of that region, and
> + * occupies half of it on hash CPUs and a quarter of it on Book3E
> + * (we keep a quarter for the virtual memmap)
> + */
> +#define VMALLOC_START	KERN_VIRT_START
> +#ifdef CONFIG_PPC_BOOK3E
> +#define VMALLOC_SIZE	(KERN_VIRT_SIZE >> 2)
> +#else
> +#define VMALLOC_SIZE	(KERN_VIRT_SIZE >> 1)
> +#endif
> +#define VMALLOC_END	(VMALLOC_START + VMALLOC_SIZE)
> +
> +/*
> + * The second half of the kernel virtual space is used for IO mappings,
> + * it's itself carved into the PIO region (ISA and PHB IO space) and
> + * the ioremap space
> + *
> + *  ISA_IO_BASE = KERN_IO_START, 64K reserved area
> + *  PHB_IO_BASE = ISA_IO_BASE + 64K to ISA_IO_BASE + 2G, PHB IO spaces
> + * IOREMAP_BASE = ISA_IO_BASE + 2G to VMALLOC_START + PGTABLE_RANGE
> + */
> +#define KERN_IO_START	(KERN_VIRT_START + (KERN_VIRT_SIZE >> 1))
> +#define FULL_IO_SIZE	0x80000000ul
> +#define  ISA_IO_BASE	(KERN_IO_START)
> +#define  ISA_IO_END	(KERN_IO_START + 0x10000ul)
> +#define  PHB_IO_BASE	(ISA_IO_END)
> +#define  PHB_IO_END	(KERN_IO_START + FULL_IO_SIZE)
> +#define IOREMAP_BASE	(PHB_IO_END)
> +#define IOREMAP_END	(KERN_VIRT_START + KERN_VIRT_SIZE)
> +
> +
> +/*
> + * Region IDs
> + */
> +#define REGION_SHIFT		60UL
> +#define REGION_MASK		(0xfUL << REGION_SHIFT)
> +#define REGION_ID(ea)		(((unsigned long)(ea)) >> REGION_SHIFT)
> +
> +#define VMALLOC_REGION_ID	(REGION_ID(VMALLOC_START))
> +#define KERNEL_REGION_ID	(REGION_ID(PAGE_OFFSET))
> +#define VMEMMAP_REGION_ID	(0xfUL)	/* Server only */
> +#define USER_REGION_ID		(0UL)
> +
> +/*
> + * Defines the address of the vmemap area, in its own region on
> + * hash table CPUs and after the vmalloc space on Book3E
> + */
> +#ifdef CONFIG_PPC_BOOK3E
> +#define VMEMMAP_BASE		VMALLOC_END
> +#define VMEMMAP_END		KERN_IO_START
> +#else
> +#define VMEMMAP_BASE		(VMEMMAP_REGION_ID << REGION_SHIFT)
> +#endif
> +#define vmemmap			((struct page *)VMEMMAP_BASE)
> +
> +#ifdef CONFIG_PPC_MM_SLICES
> +#define HAVE_ARCH_UNMAPPED_AREA
> +#define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
> +#endif /* CONFIG_PPC_MM_SLICES */
> +
> +#endif
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
> index 4a191c472867..9935e9b79524 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -1,102 +1,8 @@
>  #ifndef _ASM_POWERPC_PGTABLE_PPC64_H_
>  #define _ASM_POWERPC_PGTABLE_PPC64_H_
> -/*
> - * This file contains the functions and defines necessary to modify and use
> - * the ppc64 hashed page table.
> - */
> -
> -#ifdef CONFIG_PPC_64K_PAGES
> -#include <asm/pgtable-ppc64-64k.h>
> -#else
> -#include <asm/pgtable-ppc64-4k.h>
> -#endif
> -#include <asm/barrier.h>
> -
> -#define FIRST_USER_ADDRESS	0
> -
> -/*
> - * Size of EA range mapped by our pagetables.
> - */
> -#define PGTABLE_EADDR_SIZE (PTE_INDEX_SIZE + PMD_INDEX_SIZE + \
> -                	    PUD_INDEX_SIZE + PGD_INDEX_SIZE + PAGE_SHIFT)
> -#define PGTABLE_RANGE (ASM_CONST(1) << PGTABLE_EADDR_SIZE)
> -
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -#define PMD_CACHE_INDEX	(PMD_INDEX_SIZE + 1)
> -#else
> -#define PMD_CACHE_INDEX	PMD_INDEX_SIZE
> -#endif
> -/*
> - * Define the address range of the kernel non-linear virtual area
> - */
> -
> -#ifdef CONFIG_PPC_BOOK3E
> -#define KERN_VIRT_START ASM_CONST(0x8000000000000000)
> -#else
> -#define KERN_VIRT_START ASM_CONST(0xD000000000000000)
> -#endif
> -#define KERN_VIRT_SIZE	ASM_CONST(0x0000100000000000)
> -
> -/*
> - * The vmalloc space starts at the beginning of that region, and
> - * occupies half of it on hash CPUs and a quarter of it on Book3E
> - * (we keep a quarter for the virtual memmap)
> - */
> -#define VMALLOC_START	KERN_VIRT_START
> -#ifdef CONFIG_PPC_BOOK3E
> -#define VMALLOC_SIZE	(KERN_VIRT_SIZE >> 2)
> -#else
> -#define VMALLOC_SIZE	(KERN_VIRT_SIZE >> 1)
> -#endif
> -#define VMALLOC_END	(VMALLOC_START + VMALLOC_SIZE)
> -
> -/*
> - * The second half of the kernel virtual space is used for IO mappings,
> - * it's itself carved into the PIO region (ISA and PHB IO space) and
> - * the ioremap space
> - *
> - *  ISA_IO_BASE = KERN_IO_START, 64K reserved area
> - *  PHB_IO_BASE = ISA_IO_BASE + 64K to ISA_IO_BASE + 2G, PHB IO spaces
> - * IOREMAP_BASE = ISA_IO_BASE + 2G to VMALLOC_START + PGTABLE_RANGE
> - */
> -#define KERN_IO_START	(KERN_VIRT_START + (KERN_VIRT_SIZE >> 1))
> -#define FULL_IO_SIZE	0x80000000ul
> -#define  ISA_IO_BASE	(KERN_IO_START)
> -#define  ISA_IO_END	(KERN_IO_START + 0x10000ul)
> -#define  PHB_IO_BASE	(ISA_IO_END)
> -#define  PHB_IO_END	(KERN_IO_START + FULL_IO_SIZE)
> -#define IOREMAP_BASE	(PHB_IO_END)
> -#define IOREMAP_END	(KERN_VIRT_START + KERN_VIRT_SIZE)
> -
> -
> -/*
> - * Region IDs
> - */
> -#define REGION_SHIFT		60UL
> -#define REGION_MASK		(0xfUL << REGION_SHIFT)
> -#define REGION_ID(ea)		(((unsigned long)(ea)) >> REGION_SHIFT)
> -
> -#define VMALLOC_REGION_ID	(REGION_ID(VMALLOC_START))
> -#define KERNEL_REGION_ID	(REGION_ID(PAGE_OFFSET))
> -#define VMEMMAP_REGION_ID	(0xfUL)	/* Server only */
> -#define USER_REGION_ID		(0UL)
> -
> -/*
> - * Defines the address of the vmemap area, in its own region on
> - * hash table CPUs and after the vmalloc space on Book3E
> - */
> -#ifdef CONFIG_PPC_BOOK3E
> -#define VMEMMAP_BASE		VMALLOC_END
> -#define VMEMMAP_END		KERN_IO_START
> -#else
> -#define VMEMMAP_BASE		(VMEMMAP_REGION_ID << REGION_SHIFT)
> -#endif
> -#define vmemmap			((struct page *)VMEMMAP_BASE)
>  
> +#include <asm/pgtable-ppc64-range.h>
>  
> -/*
> - * Include the PTE bits definitions
> - */
>  #ifdef CONFIG_PPC_BOOK3S
>  #include <asm/pte-hash64.h>
>  #else
> @@ -104,11 +10,6 @@
>  #endif
>  #include <asm/pte-common.h>
>  
> -#ifdef CONFIG_PPC_MM_SLICES
> -#define HAVE_ARCH_UNMAPPED_AREA
> -#define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
> -#endif /* CONFIG_PPC_MM_SLICES */
> -
>  #ifndef __ASSEMBLY__
>  
>  /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
