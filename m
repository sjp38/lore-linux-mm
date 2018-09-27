Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6DE8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 00:52:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i68-v6so1522781pfb.9
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 21:52:54 -0700 (PDT)
Received: from mail142-4.mail.alibaba.com (mail142-4.mail.alibaba.com. [198.11.142.4])
        by mx.google.com with ESMTPS id bf9-v6si1035062plb.507.2018.09.26.21.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 21:52:53 -0700 (PDT)
Date: Thu, 27 Sep 2018 12:52:38 +0800
From: Guo Ren <ren_guo@c-sky.com>
Subject: Re: [PATCH] csky: fixups after bootmem removal
Message-ID: <20180927045237.GA2820@guoren>
References: <20180926112744.GC4628@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926112744.GC4628@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2018 at 02:27:45PM +0300, Mike Rapoport wrote:
> Hi,
> 
> The below patch fixes the bootmem leftovers in csky. It is based on the
> current mmots and csky build there fails because of undefined reference to
> dma_direct_ops: 
> 
>   MODPOST vmlinux.o
> kernel/dma/mapping.o: In function `dmam_alloc_attrs':
> kernel/dma/mapping.c:143: undefined reference to `dma_direct_ops'
> kernel/dma/mapping.o: In function `dmam_declare_coherent_memory':
> kernel/dma/mapping.c:184: undefined reference to `dma_direct_ops'
> mm/dmapool.o: In function `dma_free_attrs': 
> include/linux/dma-mapping.h:558: undefined reference to `dma_direct_ops'
> 
> I've blindly added "select DMA_DIRECT_OPS" to arch/csky/Kconfig and it
> fixed the build, but I really have no idea if this the right thing to do...
You are almost right, the issue is come from the patch:
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=bc3ec75de5452db59b683487867ba562b950708a

we need:
-	select DMA_NONCOHERENT_OPS
+	select DMA_DIRECT_OPS

I'll fixup it in my repo.

> From 63c3b24e661e6cad88f0432dd460d35a16741871 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Date: Wed, 26 Sep 2018 13:40:13 +0300
> Subject: [PATCH] csky: fixups after bootmem removal
> 
> The bootmem removal patchest didn't take into account csky architecture and
> it still had bootmem leftovers. Remove them now.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  arch/csky/Kconfig        | 1 -
>  arch/csky/kernel/setup.c | 1 -
>  arch/csky/mm/highmem.c   | 4 ++--
>  arch/csky/mm/init.c      | 3 +--
>  4 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
> index fb2a0ae..fc25ea6 100644
> --- a/arch/csky/Kconfig
> +++ b/arch/csky/Kconfig
> @@ -35,7 +35,6 @@ config CSKY
>  	select HAVE_C_RECORDMCOUNT
>  	select HAVE_DMA_API_DEBUG
>  	select HAVE_DMA_CONTIGUOUS
> -	select HAVE_MEMBLOCK
>  	select MAY_HAVE_SPARSE_IRQ
>  	select MODULES_USE_ELF_RELA if MODULES
>  	select OF
> diff --git a/arch/csky/kernel/setup.c b/arch/csky/kernel/setup.c
> index 27f9e10..bee4d26 100644
> --- a/arch/csky/kernel/setup.c
> +++ b/arch/csky/kernel/setup.c
> @@ -3,7 +3,6 @@
>  
>  #include <linux/console.h>
>  #include <linux/memblock.h>
> -#include <linux/bootmem.h>
>  #include <linux/initrd.h>
>  #include <linux/of.h>
>  #include <linux/of_fdt.h>
> diff --git a/arch/csky/mm/highmem.c b/arch/csky/mm/highmem.c
> index 149921a..5b90501 100644
> --- a/arch/csky/mm/highmem.c
> +++ b/arch/csky/mm/highmem.c
> @@ -4,7 +4,7 @@
>  #include <linux/module.h>
>  #include <linux/highmem.h>
>  #include <linux/smp.h>
> -#include <linux/bootmem.h>
> +#include <linux/memblock.h>
>  #include <asm/fixmap.h>
>  #include <asm/tlbflush.h>
>  #include <asm/cacheflush.h>
> @@ -138,7 +138,7 @@ static void __init fixrange_init (unsigned long start, unsigned long end,
>  			pmd = (pmd_t *)pud;
>  			for (; (k < PTRS_PER_PMD) && (vaddr != end); pmd++, k++) {
>  				if (pmd_none(*pmd)) {
> -					pte = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
> +					pte = (pte_t *) memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
>  					set_pmd(pmd, __pmd(__pa(pte)));
>  					BUG_ON(pte != pte_offset_kernel(pmd, 0));
>  				}
> diff --git a/arch/csky/mm/init.c b/arch/csky/mm/init.c
> index fd2791b..46c5aaa 100644
> --- a/arch/csky/mm/init.c
> +++ b/arch/csky/mm/init.c
> @@ -14,7 +14,6 @@
>  #include <linux/ptrace.h>
>  #include <linux/mman.h>
>  #include <linux/mm.h>
> -#include <linux/bootmem.h>
>  #include <linux/highmem.h>
>  #include <linux/memblock.h>
>  #include <linux/swap.h>
> @@ -44,7 +43,7 @@ void __init mem_init(void)
>  #endif
>  	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
>  
> -	free_all_bootmem();
> +	memblock_free_all();
>  
>  #ifdef CONFIG_HIGHMEM
>  	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
The patch looks good for me.

Thx
 Guo Ren
