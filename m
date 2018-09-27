Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 449F38E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:47:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y8-v6so720823pfl.11
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:47:11 -0700 (PDT)
Received: from smtp2200-217.mail.aliyun.com (smtp2200-217.mail.aliyun.com. [121.197.200.217])
        by mx.google.com with ESMTPS id u7-v6si2243794pfu.143.2018.09.27.06.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 06:47:09 -0700 (PDT)
Date: Thu, 27 Sep 2018 21:47:05 +0800
From: Guo Ren <ren_guo@c-sky.com>
Subject: Re: [PATCH] csky: fixups after bootmem removal
Message-ID: <20180927134705.GA6376@guoren>
References: <20180926112744.GC4628@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926112744.GC4628@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Christoph,

Don't forget arch/csky for the patch:
dma-mapping: merge direct and noncoherent ops.

arch/csky/Kconfig

-	select DMA_NONCOHERENT_OPS
+	select DMA_DIRECT_OPS

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=bc3ec75de5452db59b683487867ba562b950708a

Thx!
 Guo Ren

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
> 
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
> -- 
> 2.7.4
> 
> -- 
> Sincerely yours,
> Mike.
