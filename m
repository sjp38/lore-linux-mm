Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 347378E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 09:59:54 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h11so12069042pfj.13
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 06:59:54 -0800 (PST)
Received: from mailgate-2.ics.forth.gr (mailgate-2.ics.forth.gr. [139.91.1.5])
        by mx.google.com with ESMTPS id 91si11041113ply.222.2018.12.17.06.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 06:59:52 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Mon, 17 Dec 2018 16:59:19 +0200
From: Nick Kossifidis <mick@ics.forth.gr>
Subject: Re: [PATCH v2 6/6] RISC-V: Implement sparsemem
In-Reply-To: <20181015175702.9036-7-logang@deltatee.com>
References: <20181015175702.9036-1-logang@deltatee.com>
 <20181015175702.9036-7-logang@deltatee.com>
Message-ID: <4b591ba933363e29392dba218ef63267@mailhost.ics.forth.gr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Rob Herring <robh@kernel.org>, Albert Ou <aou@eecs.berkeley.edu>, Andrew Waterman <andrew@sifive.com>, Arnd Bergmann <arnd@arndb.de>, Palmer Dabbelt <palmer@sifive.com>, Stephen Bates <sbates@raithlin.com>, Zong Li <zong@andestech.com>, Olof Johansson <olof@lixom.net>, Andrew Morton <akpm@linux-foundation.org>, Michael Clark <michaeljclark@mac.com>, Christoph Hellwig <hch@lst.de>

Hello Logan,

Στις 2018-10-15 20:57, Logan Gunthorpe έγραψε:
> This patch implements sparsemem support for risc-v which helps pave the
> way for memory hotplug and eventually P2P support.
> 
> We introduce Kconfig options for virtual and physical address bits 
> which
> are used to calculate the size of the vmemmap and set the
> MAX_PHYSMEM_BITS.
> 
> The vmemmap is located directly before the VMALLOC region and sized
> such that we can allocate enough pages to populate all the virtual
> address space in the system (similar to the way it's done in arm64).
> 
> During initialization, call memblocks_present() and sparse_init(),
> and provide a stub for vmemmap_populate() (all of which is similar to
> arm64).
> 
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
> Cc: Albert Ou <aou@eecs.berkeley.edu>
> Cc: Andrew Waterman <andrew@sifive.com>
> Cc: Olof Johansson <olof@lixom.net>
> Cc: Michael Clark <michaeljclark@mac.com>
> Cc: Rob Herring <robh@kernel.org>
> Cc: Zong Li <zong@andestech.com>
> ---
>  arch/riscv/Kconfig                 | 23 +++++++++++++++++++++++
>  arch/riscv/include/asm/pgtable.h   | 21 +++++++++++++++++----
>  arch/riscv/include/asm/sparsemem.h | 11 +++++++++++
>  arch/riscv/kernel/setup.c          |  4 +++-
>  arch/riscv/mm/init.c               |  8 ++++++++
>  5 files changed, 62 insertions(+), 5 deletions(-)
>  create mode 100644 arch/riscv/include/asm/sparsemem.h
> 
> diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
> index a344980287a5..a1b5d758a542 100644
> --- a/arch/riscv/Kconfig
> +++ b/arch/riscv/Kconfig
> @@ -52,12 +52,32 @@ config ZONE_DMA32
>  	bool
>  	default y if 64BIT
> 
> +config VA_BITS
> +	int
> +	default 32 if 32BIT
> +	default 39 if 64BIT
> +
> +config PA_BITS
> +	int
> +	default 34 if 32BIT
> +	default 56 if 64BIT
> +
>  config PAGE_OFFSET
>  	hex
>  	default 0xC0000000 if 32BIT && MAXPHYSMEM_2GB
>  	default 0xffffffff80000000 if 64BIT && MAXPHYSMEM_2GB
>  	default 0xffffffe000000000 if 64BIT && MAXPHYSMEM_128GB
> 
> +config ARCH_FLATMEM_ENABLE
> +	def_bool y
> +
> +config ARCH_SPARSEMEM_ENABLE
> +	def_bool y
> +	select SPARSEMEM_VMEMMAP_ENABLE
> +
> +config ARCH_SELECT_MEMORY_MODEL
> +	def_bool ARCH_SPARSEMEM_ENABLE
> +
>  config STACKTRACE_SUPPORT
>  	def_bool y
> 
> @@ -92,6 +112,9 @@ config PGTABLE_LEVELS
>  config HAVE_KPROBES
>  	def_bool n
> 
> +config HAVE_ARCH_PFN_VALID
> +	def_bool y
> +
>  menu "Platform type"
> 
>  choice
> diff --git a/arch/riscv/include/asm/pgtable.h 
> b/arch/riscv/include/asm/pgtable.h
> index 16301966d65b..e1162336f5ea 100644
> --- a/arch/riscv/include/asm/pgtable.h
> +++ b/arch/riscv/include/asm/pgtable.h
> @@ -89,6 +89,23 @@ extern pgd_t swapper_pg_dir[];
>  #define __S110	PAGE_SHARED_EXEC
>  #define __S111	PAGE_SHARED_EXEC
> 
> +#define VMALLOC_SIZE     (KERN_VIRT_SIZE >> 1)
> +#define VMALLOC_END      (PAGE_OFFSET - 1)
> +#define VMALLOC_START    (PAGE_OFFSET - VMALLOC_SIZE)
> +
> +/*
> + * Roughly size the vmemmap space to be large enough to fit enough
> + * struct pages to map half the virtual address space. Then
> + * position vmemmap directly below the VMALLOC region.
> + */
> +#define VMEMMAP_SHIFT \
> +	(CONFIG_VA_BITS - PAGE_SHIFT - 1 + STRUCT_PAGE_MAX_SHIFT)
> +#define VMEMMAP_SIZE	(1UL << VMEMMAP_SHIFT)
> +#define VMEMMAP_END	(VMALLOC_START - 1)
> +#define VMEMMAP_START	(VMALLOC_START - VMEMMAP_SIZE)
> +
> +#define vmemmap		((struct page *)VMEMMAP_START)
> +
>  /*
>   * ZERO_PAGE is a global shared page that is always zero,
>   * used for zero-mapped memory areas, etc.
> @@ -411,10 +428,6 @@ static inline void pgtable_cache_init(void)
>  	/* No page table caches to initialize */
>  }
> 
> -#define VMALLOC_SIZE     (KERN_VIRT_SIZE >> 1)
> -#define VMALLOC_END      (PAGE_OFFSET - 1)
> -#define VMALLOC_START    (PAGE_OFFSET - VMALLOC_SIZE)
> -
>  /*
>   * Task size is 0x40000000000 for RV64 or 0xb800000 for RV32.
>   * Note that PGDIR_SIZE must evenly divide TASK_SIZE.
> diff --git a/arch/riscv/include/asm/sparsemem.h
> b/arch/riscv/include/asm/sparsemem.h
> new file mode 100644
> index 000000000000..215530b24336
> --- /dev/null
> +++ b/arch/riscv/include/asm/sparsemem.h
> @@ -0,0 +1,11 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +
> +#ifndef __ASM_SPARSEMEM_H
> +#define __ASM_SPARSEMEM_H
> +
> +#ifdef CONFIG_SPARSEMEM
> +#define MAX_PHYSMEM_BITS	CONFIG_PA_BITS
> +#define SECTION_SIZE_BITS	30

Having memory blocks of a minimum size of 1GB doesn't make much sense. 
It makes it harder to implement hotplug on top of this since we'll only 
able to add/remove 1GB at a time. ARM used to do the same and they 
switched to 27bits (https://patchwork.kernel.org/patch/9172845/), ARM64 
still uses 1GB, x86 also uses 27bits and most archs also use something 
below 30. I believe we should go for 27bits as well or even better have 
this as a compile time option.

BTW memblocks_present is on master now (got merged 3 days ago).

Regards,
N.
